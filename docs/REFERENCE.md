# Reference

The `./bootstrap.sh` script is executed on container run and it contains logic that detects the container status (stopped or new), it provides Chevereto application code using the [Installer](https://github.com/chevereto/installer) on first-run.

The containers are intend to be used in systems where once the container gets created, it is then either stopped or started (not removed).

For disposable container-based provisioning (application provided at image layer) check our [chevereto/container-builder](https://github.com/chevereto/container-builder) repository.

## Port reference

Ports used in this project follow a 5-char convention. For example, `14080` represents `production 4.0 php 8.0`.

`1 23 45`

* Char at pos `1` is for purpose:
  * 1: Prod
  * 2: Demo
  * 3: Dev database
  * 4: Dev app
* Chars at post `2` and pos `3` are for Chevereto version: `40` for 4.0.
* Chars at post `4` and pos `5` are for PHP version: `80` for 8.0.
