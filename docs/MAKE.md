# Make

[Makefile](../Makefile) commands must pass `v` (Chevereto version) and `php` arguments.

*Note:* Pass `user=<user>` to set the user for run commands. Default `www-data`.

```sh
make <command> version=4.0 php=8.0
```

💡 The `make` commands are destructive. Use it only to spawn new disposable instances.

## Production

A production instance is *ready to be installed*. It is used in production and to spawn a blank ready-to-install instances.

💡 It requires a [Chevereto license](https://chevereto.com/pricing) key.

* To build a production instance:

```sh
make prod version=4.0 php=8.0
```

* To takedown a production instance:

```sh
make prod--down version=4.0 php=8.0
```

## Demo

A demo instance is *already installed*, with an admin user and with content provided by [demo-importing](https://github.com/chevereto/demo-importing). It is used for demo, to spawn an instance with content for end-users.

💡 It requires a [Chevereto license](https://chevereto.com/pricing) key.

* To build a demo instance:

```sh
make demo version=4.0 php=8.0
```

* To takedown a demo instance:

```sh
make demo--down version=4.0 php=8.0
```

## Dev

A dev instance is used when you have a Chevereto project in your system (`SOURCE` argument). A Chevereto project is any folder containing Chevereto code, including your own modified versions.

💡 It requires a Chevereto project.

* To build a dev instance:

```sh
make dev SOURCE=~/git/chevereto/v4 version=4.0 php=8.0
```

* To takedown a dev instance:

```sh
make dev--down version=4.0 php=8.0
```

* To implement demo on dev:

```sh
make dev--demo version=4.0 php=8.0
```

* To run composer `update` on dev:

```sh
make dev--composer run=update version=4.0 php=8.0
```

* To run composer `install` on dev:

```sh
make dev--composer run=install version=4.0 php=8.0
```

* To run `sync` script on dev instance:

💡 It syncs your `SOURCE` with the code running in the container.

```sh
make dev--sh run=sync version=4.0 php=8.0
```

* To run `observe` script on dev instance:

💡 Same as sync, but observe `SOURCE` for auto re-sync.

```sh
make dev--sh run=observe version=4.0 php=8.0
```

## Logs

To retrieve and follow the error log:

```sh
make log-error version=4.0 php=8.0
```

To retrieve and follow the access log:

```sh
make log-access version=4.0 php=8.0
```
