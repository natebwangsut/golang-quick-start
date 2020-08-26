# Golang Quick Start

Quick Start Template for Golang (with Go Modules for `1.15`)

## Utility

This repository contains a semver utility from [fmahnke/shell-semver](https://github.com/fmahnke/shell-semver).

## Container

I've designed the repository to be working as a containerised application.
The container utilises [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) to optimise the size and dependency resolutions for the application.

### Alpine

> Alpine Linux is a Linux distribution based on `musl` and `BusyBox`, designed for security, simplicity, and resource efficiency.

[Alpine Linux](https://alpinelinux.org/) is a very small and completed linux container where it should satisfies all the basic requirements.
The finalised product would be running on `alpine:3`. Any additional packages can be directly downloaded from the alpine repositories via `apk` command.

However, to compensate the size, alpine has opt to use `musl` gcc compiler. For perfomance optimisation it would recommended for go developers to compile the static library into your application as the system's C libraries will not inference with the application (`CGO_ENABLED`).

There's pros and cons of using `musl` lib, but if you're not keen of using `musl`, you can choose `glibc` on distroless option.

### Distroless

> "Distroless" images contain only your application and its runtime dependencies.

[Distroless](https://github.com/GoogleContainerTools/distroless) is the recommended way to run a container in production by Google.
Restricting what's in your runtime container to the only necessary items are yield fast and secure container.
It reduces a potential CVE that you might face with the underlying dependencies.

Be warned that distroless images lacks of shell access thus, meaning that it is impossible to enter the container to troubleshooting the applications.
