# Reference

## Docker alternatives

👉 At Chevereto we provide two docker based alternatives, choose the one that suit your needs and use-case. If you aren't sure, you can always start a [discussion](https://github.com/chevereto/v4-docker/discussions) to get help.

### chevereto/v4-docker

* [chevereto/v4-docker](https://github.com/chevereto/v4-docker) (this repo)

The [bootstrap.sh](../scripts/bootstrap.sh) script is executed on container run and it contains logic that detects the container status. It provides Chevereto application code on first container run, the software is downloaded every time you create a container.

This provisioning is intended to be used in systems where once the container gets created, it is either stopped or re-started (not removed).

👉 Use `chevereto/v4-docker` when needing to work on Chevereto, test a functionality or checking for bugs.

* Doesn't require to build system images (we publish those)
* Application files in a shared volume
* Enables to builds PHP & VERSION variants
* Provides development project with automatic file-sync

### chevereto/v4-docker-production

* [chevereto/v4-docker-production](https://github.com/chevereto/v4-docker-production)

Docker provisioning at `chevere/v4-docker-production` is intended to be used in production systems as the application files are part of the container filesystem, the software is downloaded once.

👉 Use `chevereto/v4-docker-production` when needing to run Chevereto for production purposes.

* Requires to build new images (php + httpd) on each update
* Application files on container filesystem (immutable)
* Uses fixed PHP & VERSION
* Provides production-grade 12F provisioning

## Project targets

At `./projects` folder there are the docker compose files which are used to orchestrate spawning of the system containers.

👉 Do not use the `.yml` files directly! Refer to [MAKE](MAKE.md) to issue commands.

### prod.yml

💡 Use `prod` target when needing to spawn a production-like(*) provisioning.

The target at [prod.yml](../projects/prod.yml) describes a system that will bootstrap a Chevereto instance. It should be used to try the software as to see how it works and/or to debug an alleged error in the application.

(*) Production-like: We recommend checking [container-builder](https://github.com/chevereto/container-builder) for production provisioning.

### demo.yml

💡 Use `demo` target when needing to try the software with dummy content.

The target at [demo.yml](../projects/demo.yml) describes the same system  with demo content loaded from [demo-importing](https://github.com/chevereto/demo-importing). It should be used to try the software as to see how it works and/or to debug an alleged error in the application.

### dev.yml

💡 Use `dev` target when needing to work on Chevereto source code.

The target at [dev.yml](../projects/dev.yml) describes a system that will sync the application source code from a local filesystem path. It should be used when the Chevereto source code exists as a project folder in your system.

## Ports

Ports used in this project follow a 5-char convention. For example, `14080` represents `production 4.0 php 8.0`.

* Port: `1 40 80`
* Pos.: `1 23 45`

| Char pos | Purpose                            |
| -------- | ---------------------------------- |
| 1        | Project flag                       |
| 23       | Chevereto version (`40` for `4.0`) |
| 45       | PHP version (`80` for `8.0`)       |

| Project flag | Description       |
| ------------ | ----------------- |
| 1            | Production (prod) |
| 2            | Demo              |
| 3            | Dev database      |
| 4            | Dev application   |

### Multiple versions

With this provisioning you can spawn multiple container versions by switching Chevereto version and PHP.

Table below provide examples:

| Port  | Application            |
| ----- | ---------------------- |
| 14080 | Production 4.0 PHP 8.0 |
| 14181 | Production 4.1 PHP 8.1 |
| 24080 | Demo 4.0 PHP 8.0       |
| 24181 | Demo 4.1 PHP 8.1       |
| 44080 | Dev 4.0 PHP 8.0        |
| 44180 | Dev 4.1 PHP 8.1        |
