# phpv
Bash script to update version of PHP CLI, PHP Apache2 and Composer

## Installation

How add bash script to system ?
```sh
# make file executable
chmod -x ./phpv.sh
# create symbolic link in bin directory
ln -s ./phpv.sh /usr/bin/phpv
```

## Usage

```sh
phpv [OPTION]... PHP_CLI_VERSION COMPOSER_VERSION [PHP_APACHE2_VERSION]
```

Mandatory arguments to long options are mandatory for short options too.

| options | required | default | description        |
|---------|----------|---------|--------------------|
| -h      | no       |         | Print this Help.   |
| -v      | no       | false   | Verbose mode.      |

If PHP APACHE2 version is not specified, PHP CLI VERSION will be applied.
If PHP CLI version and COMPOSER version were not specified, they will be asked interactively.

## License

MIT