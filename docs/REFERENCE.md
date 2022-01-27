# Reference

The `./bootstrap.sh` script is executed on container run and it contains logic that detects the container status (stopped or new), it provides Chevereto application code using the [Installer](https://github.com/chevereto/installer) on first-run.

The containers are intend to be used in systems where once the container gets created, it is then either stopped or started (not removed).

For disposable container-based provisioning (application provided at image layer) check our [chevereto/container-builder](https://github.com/chevereto/container-builder) repository.

## Port reference

Ports used in this project follow a 5-char convention.

`12 34 5`

* Chars `1` and `2` are for Chevereto version: `40`.
* Chars `3` and `4` are for PHP version: `80`.
* Char `5` is for purpose:
  * 0: Prod
  * 1: Demo
  * 9: dev
