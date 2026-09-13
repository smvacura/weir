from dataclasses import dataclass, asdict, fields
from enum import StrEnum
import subprocess
import json
import re
import csv
import shutil
import base64
import argparse
import logging
import time
from contextlib import contextmanager
from pathlib import Path

log = logging.getLogger("oracle")


@contextmanager
def timed(label):
    start = time.monotonic()
    log.info("%s: start", label)
    try:
        yield
    finally:
        log.info("%s: %.1fs", label, time.monotonic() - start)

MODEL = "gpt-6-astra"

DEFAULT_SRC_PORT = 40000
PROBE_TIMEOUT = 3

REGIONS = ["eastus", "eastus2", "centralus", "westus2", "westus3"]
MAX_VCPUS_PER_VM = 2
MIN_VMS = 4
MAX_VMS_CAP = 6

PROVIDERS = Path(__file__).resolve().parent / "providers.tf"


def executable(name):
    found = shutil.which(name)
    if found is None:
        raise FileNotFoundError(f"{name} is not on PATH")
    return found


CODEX = executable("codex")
TERRAFORM = executable("terraform")
AZ = executable("az")

LIVE_PLANS = Path(__file__).resolve().parent.parent / "weir" / "reference" / "live_plans"

COLUMNS = ["src_addr", "dst_addr", "protocol", "dest_port", "src_port", "why"]
HEADER = "\t".join(COLUMNS)

GENERATION_PROMPT = """
You are authoring a Terraform fixture and a probe list for an empirical test of
  Azure networking semantics. The fixture will be applied to a real Azure
  subscription, then torn down. Each probe is one TCP connection attempt made
  from inside a source VM to a destination address and port, run through
  `az vm run-command`; its outcome is connected, refused, or dropped. The
  results become ground truth for a verification tool, so a wrong or imprecise
  fixture produces a wrong statement about Azure.

  ## Question under test

  {SEMANTICS}

  ## What you produce

  1. `main.tf`, written to the working directory.
  2. `probes.tsv`, written to the working directory.


  ## Fixture rules

  - HCL only, never JSON.
  - No root input variables. The harness runs terraform with no `-var` and no
    tfvars file, so every value must be written into the configuration.
  - No `provider` block, no `terraform` block, no backend configuration. These are
    supplied at apply time and a duplicate will fail the apply.
  - One resource group, declared in this file. Every resource belongs to it.
  - Prefix every resource name with the scenario slug so two scenarios deployed
    concurrently cannot collide. Azure names may contain only lowercase
    letters, digits and hyphens: replace any other character in the slug,
    including underscores, with a hyphen. A virtual machine's name becomes its
    computer name, which rejects underscores outright.
  - Smallest deployment that can answer the question. Every resource must be
    load-bearing: if deleting it would change no probe's outcome, delete it.
  - Deploy to location `{REGION}`.
  - Any subnet that is a probe source or destination needs a running Linux VM
    with a NIC in that subnet: size `{VM_SIZE}`, image
    `Canonical / ubuntu-24_04-lts / {IMAGE_SKU} / latest`. That size and image
    were selected against live quota and regional availability; do not
    substitute another.
  - At most {MAX_VMS} virtual machines in the whole fixture. That is what the
    subscription's remaining vCPU quota allows. Economise: one VM can be the
    source of many probes, and one destination VM with a public IP serves both
    as a private-address destination and, through that public address, as a
    destination outside the virtual network. If the question needs more
    machines than that, cover what you can within the limit and say in your
    final message which cases you had to drop.
  - Generate the admin SSH key inside the fixture with a `tls_private_key`
    resource and feed its `public_key_openssh` into `admin_ssh_key`. Never run
    ssh-keygen and never reference a key file on disk: the fixture must apply
    from a clean checkout with no other files present.
  - No VM extensions. Probes run through `az vm run-command`, which uses the
    Azure VM agent already present in the image.
  - Static private IP allocation unless the question specifically concerns
    dynamic allocation.
  - Every `ip_configuration` name must be a plain string literal, with no
    interpolation, no `local`, and no `each.key`. The plan parser matches an
    ip_configuration by its literal name, and an interpolated one makes the
    whole NIC unparseable. Other resource names may be interpolated.
  - No data sources that read pre-existing infrastructure. The fixture must be
    self-contained.
  - A security rule may constrain source ports. The harness binds each probe's
    source port explicitly, so the value in the probe's src_port column is the
    port that reaches the wire.

  ## Probe rules

  - One row per packet to test. Endpoints are Terraform resource addresses, not
    IP addresses; IPs are resolved from state after apply.
  - Every probe carries a `why`: the specific thing about the question above that
    this packet resolves.
  - State no expectations. There is no expected-result field and you must not put
    one in `why`. Azure answers the question, not you. A probe whose answer you
    are already certain of is not worth running.
  - Aim at boundaries: the address one outside a prefix, the port at the edge of
    a range, the priority between two rules, the direction that is usually
    implicit, the case the documentation leaves ambiguous.
  - Between 6 and 15 probes.
  - probes.tsv is tab-separated. Its first line is exactly these column names in
    this order, separated by single tab characters:

      {HEADER}

    One probe per line, fields separated by single tab characters. No field may
    contain a tab. The protocol column is one of `Tcp`, `Udp` or `Icmp`; every
    probe that the harness can actually run is `Tcp`.
  - Leave src_port empty unless the question concerns source ports, in which
    case name the port you want. An empty column means 40000. The harness binds
    whichever value it is, so the recorded port is the one that was used.

  ## Before you finish

  You have no network access and no Azure credentials, so `terraform init`,
  `plan` and `apply` will all fail and must not be attempted. `terraform fmt`
  works offline and catches syntax errors; use it. Everything else has to be
  right by inspection, so re-read the configuration against the rules above
  before you finish.

  ## Notes

  - azurerm provider, recent 4.x. The `tls` provider is available.
  - If the question cannot be settled by observing TCP connection attempts
    between VMs, say so in your final message instead of inventing a fixture
    that appears to answer it.
"""

class Protocol(StrEnum):
    TCP = "Tcp"
    UDP = "Udp"
    ICMP = "Icmp"

    @classmethod
    def parse(cls, text):
        return cls(text.strip().capitalize())

class Result(StrEnum):
    CONNECTED = "Connected"
    REFUSED = "Refused"
    DROPPED = "Dropped"

RESULT_BY_RC = {
    0: Result.CONNECTED,
    1: Result.REFUSED,
    124: Result.DROPPED,
}

@dataclass
class Probe:
    src_address: str
    dest_address: str
    protocol: Protocol
    src_port: int
    dest_port: int
    why: str


@dataclass
class ProbeResult:
    src_address: str
    src_subnet: str
    src_ip: str
    dest_address: str
    dest_ip: str
    src_port: int
    dest_port: int
    protocol: Protocol
    result: Result


FORBIDDEN_HCL = [
    r"\bprovisioner\s+\"",
    r"\blocal-exec\b",
    r"\bremote-exec\b",
    r"\bresource\s+\"null_resource\"",
    r"\bresource\s+\"terraform_data\"",
    r"^\s*data\s+\"",
    r"\"external\"",
    r"\bconnection\s*\{",
]

ALLOWED_RESOURCE_TYPES = {
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_subnet",
    "azurerm_network_security_group",
    "azurerm_network_security_rule",
    "azurerm_subnet_network_security_group_association",
    "azurerm_network_interface",
    "azurerm_network_interface_security_group_association",
    "azurerm_virtual_network_peering",
    "azurerm_route_table",
    "azurerm_route",
    "azurerm_subnet_route_table_association",
    "azurerm_application_security_group",
    "azurerm_network_interface_application_security_group_association",
    "azurerm_public_ip",
    "azurerm_linux_virtual_machine",
    "tls_private_key",
}


def scan_fixture(scenario_dir):
    text = (scenario_dir / "main.tf").read_text(encoding="utf-8")
    for pattern in FORBIDDEN_HCL:
        match = re.search(pattern, text, re.MULTILINE)
        if match:
            raise PermissionError(
                f"main.tf contains a forbidden construct: {match.group(0)!r}"
            )


def planned_resources(plan):
    module = plan.get("planned_values", {}).get("root_module", {})
    return module.get("resources", [])


def check_plan(scenario_dir, expected_size, max_vms):
    plan = json.loads((scenario_dir / "plan.json").read_text(encoding="utf-8"))
    resources = planned_resources(plan)
    vms = 0
    for resource in resources:
        kind = resource["type"]
        if kind not in ALLOWED_RESOURCE_TYPES:
            raise PermissionError(f"plan creates disallowed resource type {kind}")
        if kind != "azurerm_linux_virtual_machine":
            continue
        vms += 1
        size = resource["values"].get("size")
        if size != expected_size:
            raise PermissionError(f"plan uses VM size {size}, expected {expected_size}")
    if vms > max_vms:
        raise PermissionError(f"plan creates {vms} VMs, limit is {max_vms}")
    groups = {r["values"].get("name") for r in resources
              if r["type"] == "azurerm_resource_group"}
    if len(groups) != 1:
        raise PermissionError(f"plan declares {len(groups)} resource groups, expected 1")
    log.info("plan check: %d resources, %d VMs, resource group %s",
             len(resources), vms, groups.pop())


def az_json(args):
    r = subprocess.run([AZ, *args, "-o", "json"],
                       check=True, capture_output=True, text=True, encoding="utf-8")
    return json.loads(r.stdout)


def sku_vcpus(sku):
    for capability in sku.get("capabilities", []):
        if capability["name"] == "vCPUs":
            return int(capability["value"])
    return None


def sku_architecture(sku):
    for capability in sku.get("capabilities", []):
        if capability["name"] == "CpuArchitectureType":
            return capability["value"]
    return "x64"


def sku_is_unrestricted(sku, region):
    if region.lower() not in [l.lower() for l in sku.get("locations", [])]:
        return False
    return not sku.get("restrictions")


def usable_skus(region):
    skus = az_json(["vm", "list-skus", "--location", region,
                    "--resource-type", "virtualMachines"])
    usable = []
    for sku in skus:
        vcpus = sku_vcpus(sku)
        if vcpus is None or vcpus > MAX_VCPUS_PER_VM:
            continue
        if not sku_is_unrestricted(sku, region):
            continue
        usable.append((vcpus, sku["name"], sku.get("family", ""), sku_architecture(sku)))
    return sorted(usable)


def quota_headroom(region):
    usage = az_json(["vm", "list-usage", "--location", region])
    return {u["name"]["value"].lower(): int(u["limit"]) - int(u["currentValue"])
            for u in usage}


def placement_in_region(region):
    headroom = quota_headroom(region)
    regional = headroom.get("cores", 0)
    if regional < MIN_VMS * MAX_VCPUS_PER_VM:
        return None
    for vcpus, name, family, architecture in usable_skus(region):
        family_room = headroom.get(family.lower(), 0)
        capacity = min(regional, family_room) // vcpus
        if capacity >= MIN_VMS:
            return {"region": region, "size": name, "vcpus": vcpus,
                    "architecture": architecture,
                    "max_vms": min(capacity, MAX_VMS_CAP)}
    return None


def choose_placement(regions):
    for region in regions:
        with timed(f"placement {region}"):
            found = placement_in_region(region)
        if found:
            log.info("placement: %s %s (%d vCPU, %s), up to %d VMs",
                     found["region"], found["size"], found["vcpus"],
                     found["architecture"], found["max_vms"])
            return found
    raise RuntimeError(f"no region in {regions} has quota for {MIN_VMS} VMs")


def image_sku_for(architecture):
    return "server-arm64" if architecture.lower() == "arm64" else "server"


def generate_plan_and_probes(semantics, scenario_dir, placement):
    subprocess.run(
      [CODEX, "exec", "--cd", str(scenario_dir),
       "--sandbox", "workspace-write",
       "--model", MODEL,
       "-"],
      input=GENERATION_PROMPT.format(
          SEMANTICS=semantics,
          HEADER=HEADER,
          REGION=placement["region"],
          VM_SIZE=placement["size"],
          IMAGE_SKU=image_sku_for(placement["architecture"]),
          MAX_VMS=placement["max_vms"],
      ),
      text=True,
      encoding="utf-8",
      check=True,
    )
    for name in ["main.tf", "probes.tsv"]:
        if not (scenario_dir / name).exists():
            raise FileNotFoundError(f"generation produced no {name} in {scenario_dir}")

def apply_terraform(scenario_dir, placement):
    scan_fixture(scenario_dir)
    shutil.copy(PROVIDERS, scenario_dir / PROVIDERS.name)
    subprocess.run([TERRAFORM, "init", "-input=false"], cwd=scenario_dir, check=True)
    subprocess.run([TERRAFORM, "validate"], cwd=scenario_dir, check=True)
    subprocess.run([TERRAFORM, "plan", "-input=false", "-out=tfplan"], cwd=scenario_dir, check=True)
    shown = subprocess.run(
      [TERRAFORM, "show", "-json", "tfplan"],
      cwd=scenario_dir, check=True, capture_output=True, text=True,
    )
    (scenario_dir / "plan.json").write_text(shown.stdout, encoding="utf-8")
    check_plan(scenario_dir, placement["size"], placement["max_vms"])
    subprocess.run([TERRAFORM, "apply", "-input=false", "tfplan"], cwd=scenario_dir, check=True)

def read_state(scenario_dir):
    shown = subprocess.run([TERRAFORM, "show", "-json"], cwd=scenario_dir,
                         check=True, capture_output=True, text=True)
    return json.loads(shown.stdout)["values"]["root_module"]["resources"]


def sole_ip_configuration(resource):
    configs = resource["values"]["ip_configuration"]
    if len(configs) != 1:
        raise ValueError(
            f"{resource['address']} has {len(configs)} ip_configurations; "
            "probe rows name a NIC, so which one to use is undecided"
        )
    return configs[0]


def index_nics(resources):
    index = {}
    for r in resources:
        if r["type"] != "azurerm_network_interface":
            continue
        config = sole_ip_configuration(r)
        index[r["address"]] = (r["values"]["id"],
                               config["private_ip_address"],
                               config.get("subnet_id"))
    return index


def index_subnets_by_id(resources):
    return {r["values"]["id"]: r["address"]
            for r in resources if r["type"] == "azurerm_subnet"}


def index_vms(resources):
    index = {}
    for r in resources:
        if "virtual_machine" not in r["type"]:
            continue
        index[r["address"]] = (r["values"]["id"],
                               r["values"].get("network_interface_ids", []))
    return index


def index_public_ips(resources):
    return {r["address"]: r["values"].get("ip_address")
            for r in resources if r["type"] == "azurerm_public_ip"}


def build_index(resources):
    nics = index_nics(resources)
    vms = index_vms(resources)
    return {
        "nics": nics,
        "vms": vms,
        "nic_by_id": {nic_id: (ip, subnet_id) for nic_id, ip, subnet_id in nics.values()},
        "vm_by_nic_id": {nic_id: vm_id
                         for vm_id, nic_ids in vms.values() for nic_id in nic_ids},
        "subnet_by_id": index_subnets_by_id(resources),
        "public_ips": index_public_ips(resources),
    }


def subnet_address_of(subnet_id, index):
    if subnet_id not in index["subnet_by_id"]:
        raise KeyError(f"NIC is in subnet {subnet_id}, which is not in this deployment")
    return index["subnet_by_id"][subnet_id]


def sole_nic_of_vm(address, index):
    _, nic_ids = index["vms"][address]
    if len(nic_ids) != 1:
        raise ValueError(f"{address} has {len(nic_ids)} NICs; which one to probe is undecided")
    return nic_ids[0]


def resolve_source_vm(address, index):
    if address in index["vms"]:
        nic_id = sole_nic_of_vm(address, index)
        ip, subnet_id = index["nic_by_id"][nic_id]
        return index["vms"][address][0], ip, subnet_address_of(subnet_id, index)
    if address in index["nics"]:
        nic_id, ip, subnet_id = index["nics"][address]
        if nic_id not in index["vm_by_nic_id"]:
            raise KeyError(f"probe source {address} is not attached to a virtual machine")
        return (index["vm_by_nic_id"][nic_id], ip,
                subnet_address_of(subnet_id, index))
    raise KeyError(f"probe source {address} is not a virtual machine or NIC in this deployment")


def resolve_destination_ip(address, index):
    if re.fullmatch(r"\d{1,3}(\.\d{1,3}){3}", address):
        return address
    if address in index["nics"]:
        return index["nics"][address][1]
    if address in index["vms"]:
        return index["nic_by_id"][sole_nic_of_vm(address, index)][0]
    if address in index["public_ips"]:
        ip = index["public_ips"][address]
        if not ip:
            raise ValueError(f"{address} has no allocated address")
        return ip
    raise KeyError(f"probe destination {address} resolves to no address in this deployment")


def read_probes(scenario_dir):
    probes = []
    with open(scenario_dir / "probes.tsv", "r", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE, quotechar=None)
        if reader.fieldnames != COLUMNS:
            raise ValueError(f"probes.tsv header is {reader.fieldnames}, expected {COLUMNS}")
        for row in reader:
            probes.append(
                Probe(
                    src_address=row["src_addr"],
                    dest_address=row["dst_addr"],
                    protocol=Protocol.parse(row["protocol"]),
                    src_port=int(row["src_port"]) if row["src_port"] else DEFAULT_SRC_PORT,
                    dest_port=int(row["dest_port"]),
                    why=row["why"],
                )
            )
    return probes


PROBE_BODY = """import socket
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('', {src_port}))
s.settimeout({timeout})
try:
    s.connect(('{dest_ip}', {dest_port}))
    print('rc=0')
except ConnectionRefusedError:
    print('rc=1')
except socket.timeout:
    print('rc=124')
except OSError as e:
    print('rc=%d' % (100 + e.errno))
finally:
    s.close()
"""


def probe_body(dest_ip, dest_port, src_port):
    return PROBE_BODY.format(dest_ip=dest_ip, dest_port=dest_port,
                             src_port=src_port, timeout=PROBE_TIMEOUT)


def probe_script(dest_ip, dest_port, src_port):
    encoded = base64.b64encode(
        probe_body(dest_ip, dest_port, src_port).encode("utf-8")).decode("ascii")
    return f"echo {encoded} | base64 -d | python3 -"


def invoke_probe(src_vm_id, dest_ip, dest_port, src_port):
    r = subprocess.run(
        [AZ, "vm", "run-command", "invoke",
        "--ids", src_vm_id,
        "--command-id", "RunShellScript",
        "--scripts", probe_script(dest_ip, dest_port, src_port),
        "-o", "json"],
        check=True, capture_output=True, text=True, encoding="utf-8",
    )
    message = json.loads(r.stdout)["value"][0]["message"]
    match = re.search(r"rc=(\d+)", message)
    if match is None:
        raise RuntimeError(f"no exit code in run-command output for {src_vm_id}:\n{message}")
    rc = int(match.group(1))
    if rc not in RESULT_BY_RC:
        raise RuntimeError(
            f"unmapped exit code {rc} from {src_vm_id} to {dest_ip}:{dest_port}\n{message}")
    return RESULT_BY_RC[rc]


def run_probes(scenario_dir):
    resources = read_state(scenario_dir)
    index = build_index(resources)

    probes = read_probes(scenario_dir)
    log.info("probes: %d rows, %d NICs, %d VMs, %d public IPs", len(probes),
             len(index["nics"]), len(index["vms"]), len(index["public_ips"]))

    results = []
    for probe in probes:
        src_vm_id, src_ip, src_subnet = resolve_source_vm(probe.src_address, index)
        dest_ip = resolve_destination_ip(probe.dest_address, index)
        start = time.monotonic()
        result = invoke_probe(src_vm_id, dest_ip, probe.dest_port, probe.src_port)
        log.info("probe %s:%d -> %s:%d = %s (%.1fs)",
                 src_ip, probe.src_port, dest_ip, probe.dest_port, result,
                 time.monotonic() - start)
        results.append(
            ProbeResult(
                src_address=probe.src_address,
                src_subnet=src_subnet,
                src_ip=src_ip,
                dest_address=probe.dest_address,
                dest_ip=dest_ip,
                src_port=probe.src_port,
                dest_port=probe.dest_port,
                protocol=probe.protocol,
                result=result,
            )
        )
    return results


def write_live_tsv(scenario_dir, results):
    columns = [f.name for f in fields(ProbeResult)]
    with open(scenario_dir / "live.tsv", "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=columns, delimiter="\t", lineterminator="\n",
                                quoting=csv.QUOTE_NONE, quotechar=None)
        writer.writeheader()
        for result in results:
            writer.writerow(asdict(result))


def destroy_terraform(scenario_dir):
    if not (scenario_dir / "terraform.tfstate").exists():
        log.info("no state file, nothing to destroy")
        return
    subprocess.run(
        [TERRAFORM, "destroy", "-input=false", "-auto-approve"],
        cwd=scenario_dir, check=True,
    )


def clean_scenario(scenario_dir):
    for name in [".terraform", ".terraform.lock.hcl", "tfplan", PROVIDERS.name,
                 "terraform.tfstate", "terraform.tfstate.backup"]:
        path = scenario_dir / name
        if path.is_dir():
            shutil.rmtree(path)
        elif path.exists():
            path.unlink()


def run_scenario(semantics, scenario_dir, regions):
    placement = choose_placement(regions)
    with timed("generate"):
        generate_plan_and_probes(semantics, scenario_dir, placement)
    try:
        with timed("apply"):
            apply_terraform(scenario_dir, placement)
        with timed("probe"):
            results = run_probes(scenario_dir)
        write_live_tsv(scenario_dir, results)
        log.info("wrote %s (%d rows)", scenario_dir / "live.tsv", len(results))
    finally:
        with timed("destroy"):
            destroy_terraform(scenario_dir)
        clean_scenario(scenario_dir)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("scenario")
    parser.add_argument("semantics_file", type=Path)
    parser.add_argument("--dir", type=Path)
    parser.add_argument("--region", action="append")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s", datefmt="%H:%M:%S")

    scenario_dir = args.dir or LIVE_PLANS / args.scenario
    scenario_dir.mkdir(parents=True, exist_ok=True)
    log.info("scenario %s in %s (model %s)", args.scenario, scenario_dir, MODEL)
    with timed("total"):
        run_scenario(args.semantics_file.read_text(encoding="utf-8"), scenario_dir,
                     args.region or REGIONS)


if __name__ == "__main__":
    main()
