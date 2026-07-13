# Weir
A networking verifier for Azure-based Terraform plans.

### Examples

Weir currently has two functions: `diff` and `check`.

`weir diff BEFORE AFTER` reveals the difference in traversable network routes between the two Terraform plans.

`weir check POLICY JSON` checks the given plan json against a YAML policy file. Below is a minimal policy.yaml file:

```yaml
 version: 0
  rules:
    - name: web-cannot-reach-db
      from: azurerm_subnet.web
      to: azurerm_subnet.db
      expect: unreachable
```

Weir will then check to ensure no traffic can traverse the NSGs and route tables from `azurerm_subnet.web` to `azurer_subnet.db`.
Policy rules can also restrict the subset of traffic to check:

```yaml
    - name: no-ssh-to-db
      from: azurerm_subnet.web
      to: azurerm_subnet.db
      on:
        protocol: tcp
        ports: [22]
      expect: unreachable
```

The tool will then only check packet headers with destination port 22 and protocol TCP.

### Engine

The Weir engine is built around a technique known as "Header Space Analysis." The core technique constructs a graph of nodes (places that packets can be, here just subnets and NICs) and edges (how packets go from node-to-node, here just a combination of routing and NSG rule evaluation), and then propagates a set of packets from a source node to a destination node. It is able to take advantage of the structured format and shared deciders in packet headers, as well as fast deciders in binary decision diagrams, to quickly and efficienly check the entire packet header space. Unlike static tools like OPA/Rego or live networking checkers like Azure Network Watcher, it is thus able to guarantee no undesired packets traverse from the source to destination by any path in the network. 

### Limitations

Right now, Weir only operates on a barebones set of resources, currently subnets, vnets, route tables, NSGs, NICs, and peerings. Any other resources that can impact network reachability (eg NAT gateways, Azure firewalls) can lead to the actual state of the network to diverge from the Weir modeled network. I am continuously adding new resources.

Additionally, the network flow is forward-only. Weir does not yet check that a `SYN-ACK` packet can return to the source, and thus cannot guarantee a TCP connection. I am currently adding the stateful backward pass to enable this.

### Roadmap

The first extension will be bidirectionality without NAT
