# Dev

## Reference

* `SOURCE` is the absolute path to the cloned chevereto project
* You need to replace `SOURCE=~/git/chevereto/v4` with your own path
* `SOURCE` will be mounted at `/var/www/chevereto/` inside the container

## Quick start

You will need a Chevereto V4 project:

* Using git
  * Clone the [chevereto/v4](https://github.com/chevereto/v4) repository (your clone path will be your `SOURCE`)
* Using package (zip download)
  * Download the target V4 release from [chevereto.com/panel/downloads](https://chevereto.com/panel/downloads) (your extract path will be your `SOURCE`)

From the root folder run the following [Make](./MAKE.md) command:

```sh
make dev SOURCE=/my/path VERSION=4.0 PHP=8.0
```
