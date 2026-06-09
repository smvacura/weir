# Multi-stage build for the azverify CLI.
# Build context is the azverify/ project dir (see .github/workflows/build_image.yaml).

# ---------- build ----------
FROM ocaml/opam:ubuntu-22.04-ocaml-5.4 AS build

WORKDIR /home/opam/src

# Install dependencies first so this layer is cached across source-only changes.
COPY --chown=opam:opam dune-project verifier.opam ./
RUN opam update && opam install . --deps-only --yes

# Build the azverify binary into _build/install/default/bin.
COPY --chown=opam:opam . .
RUN opam exec -- dune build --profile release @install

# ---------- runtime ----------
FROM ubuntu:22.04 AS runtime

# azverify is a stateless CLI (`azverify diff before.json after.json`); it only
# needs the native binary and glibc, which the base image already provides.
COPY --from=build /home/opam/src/_build/install/default/bin/azverify /usr/local/bin/azverify

ENTRYPOINT ["azverify"]
