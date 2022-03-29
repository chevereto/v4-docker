# Reference

The `./bootstrap.sh` script is executed on container run and it contains logic that detects the container status. It provides Chevereto application code using on first container run. This means that the software is downloaded and installed every time you spawn a new container.

This provisioning is intended to be used in systems where once the container gets created, it is then either stopped or started (not removed). For disposable container-based provisioning (application provided at image layer) check our [chevereto/container-builder](https://github.com/chevereto/container-builder) repository.

## Projects

This provisioning provides a project folder with docker compose files, which are used to orchestrate the spawining of the application containers.

👉 Do not use the `.yml` files directly! Refer to [MAKE](MAKE.md) to issue commands.

### prod.yml

💡 Use `prod` project when needing to spawn a producion-like(*) provisioning.

The projet at [prod.yml](../projects/prod.yml) describes a system that will bootstrap a Chevereto instance. It should be used to try the software as to see how it works and/or to debug an alleged error in the application.

(*) Production-like: We recommend checking [container-builder](https://github.com/chevereto/container-builder) for production provisioning.

### demo.yml

💡 Use `demo` project when needing to try the software with dummy content.

The projet at [demo.yml](../projects/demo.yml) describes the same system  with demo content loaded from [demo-importing](https://github.com/chevereto/demo-importing). It should be used to try the software as to see how it works and/or to debug an alleged error in the application.

### dev.yml

💡 Use `dev` project when needing to work on Chevereto source code.

The project at [dev.yml](../projects/dev.yml) describes a system that will sync the application source code from a local filesystem path. It should be used when the Chevereto source code exists as a project folder in your system.

## Ports

Ports used in this project follow a 5-char convention. For example, `14080` represents `production 4.0 php 8.0`.

`1 23 45`

* Char at pos `1` is for purpose:
  * 1: Prod
  * 2: Demo
  * 3: Dev (database)
  * 4: Dev
* Chars at post `2` and pos `3` are for Chevereto version: `40` for 4.0.
* Chars at post `4` and pos `5` are for PHP version: `80` for 8.0.
