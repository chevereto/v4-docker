# Make

[Makefile](../Makefile) commands must pass `v` (Chevereto version) and `php` arguments.

```sh
make <command> v=4.0 php=8.0
```

💡 The `make` commands are destructive. Use it only to spawn new disposable instances.

## Production

To build a production instance:

```sh
make prod v=4.0 php=8.0
```

To implement demo on the production instance:

```sh
make prod--demo v=4.0 php=8.0
```

## Demo

To build a demo instance:

```sh
make demo v=4.0 php=8.0
```

## Dev

To build a dev instance:

```sh
make dev SOURCE=~/git/chevereto/v4 v=4.0 php=8.0
```

To implement demo on dev:

```sh
make dev--demo v=4.0 php=8.0
```

To run a shell script on dev instance:

```sh
make dev--sh run=sync v=4.0 php=8.0
```
