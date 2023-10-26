#!/bin/bash

Help()
{
	echo "Usage: phpv [OPTION]... PHP_CLI_VERSION COMPOSER_VERSION [PHP_APACHE2_VERSION]"
	echo "Update PHP CLI and PHP APACHE2 and COMPOSER version."
	echo
	echo "Mandatory arguments to long options are mandatory for short options too."
	echo "h     Print this Help."
	echo "l     List PHP versions installed."
	echo "v     Verbose mode."
	echo
	echo "If PHP APACHE2 version is not specified, PHP CLI VERSION will be applied,"
	echo "if PHP CLI version and COMPOSER version were not specified, they will be asked interactively."
	echo
}

Execute()
{
	if [ $1 = true ]; then

		sudo update-alternatives --set php "/usr/bin/php$PHP_CLI_VERSION"

		sudo a2disconf php*.*-fpm
		sudo a2enconf "php$PHP_APACHE2_VERSION-fpm"
		sudo systemctl restart apache2

		sudo composer self-update --$COMPOSER_VERSION

	else

		sudo update-alternatives --set php "/usr/bin/php$PHP_CLI_VERSION" 1> /dev/null

		sudo a2disconf --quiet php*.*-fpm 1> /dev/null
		sudo a2enconf --quiet "php$PHP_APACHE2_VERSION-fpm" 1> /dev/null
		sudo systemctl restart apache2 1> /dev/null

		sudo composer self-update --$COMPOSER_VERSION --quiet

	fi 

	printf "\n+--------------------+---------+\n"
	printf "| PHP_CLI | $PHP_CLI_VERSION | | PHP_APACHE2 | $PHP_APACHE2_VERSION | | COMPOSER | $COMPOSER_VERSION |" | xargs -n5 printf '%-2s  %-15s  %-2s  %-5s %-2s\n'
	printf "+--------------------+---------+\n\n"
}

VERBOSE_MOD=false
PHP_CLI_VERSION=$1
COMPOSER_VERSION=$2
PHP_APACHE2_VERSION=$3

while getopts ":hlv" option; do
    case $option in
      	h)
        	Help
        	exit;;
        l)
        	PHP_CLI_VERSIONS=($(ls -d -- /usr/bin/php[0-9]*))
        	for v in "${!PHP_CLI_VERSIONS[@]}"; do echo "CLI $(basename ${PHP_CLI_VERSIONS[$v]} | sed 's/php*//')"; done
        	PHP_APACHE2_VERSIONS=($(ls -d -- /etc/apache2/conf-available/php[0-9]*))
        	for v in "${!PHP_APACHE2_VERSIONS[@]}"; do echo "FPM $(basename ${PHP_APACHE2_VERSIONS[$v]} | sed 's/php*//' | sed 's/-fpm.conf//')"; done
        	exit;;
        v)
        	VERBOSE_MOD=true
        	PHP_CLI_VERSION=$2
        	COMPOSER_VERSION=$3
        	PHP_APACHE2_VERSION=$4
        	;;
     	\?)
        	echo "Error: Invalid option"
        	exit;;
    esac
done

if [ -z "$PHP_CLI_VERSION" ]; then
    read -p "php cli version : " PHP_CLI_VERSION
fi

if [ -z "$COMPOSER_VERSION" ]; then
    read -p "composer version: " COMPOSER_VERSION
fi

if [ -z "$PHP_APACHE2_VERSION" ]; then 
	PHP_APACHE2_VERSION=$PHP_CLI_VERSION
fi

if [ ! -f "/usr/bin/php$PHP_CLI_VERSION" ]; then
	while true; do
		read -p "install PHP CLI $PHP_CLI_VERSION (y/n): " yn
		echo "installing php$PHP_CLI_VERSION, please wait ..."
		case $yn in
			[yY]) sudo apt-get -y install "php$PHP_CLI_VERSION" >> /dev/null 2>&1 && break || echo "this version of php isn't available in your depot"; exit;;
			[nN]) exit;;
			*) echo "invalid response";;
		esac
	done
fi

if [ ! -f "/etc/apache2/conf-available/php$PHP_APACHE2_VERSION-fpm.conf" ]; then
	while true; do
		read -p "install PHP FPM APACHE2 $PHP_APACHE2_VERSION (y/n): " yn
		echo "installing php$PHP_APACHE2_VERSION-fpm, please wait ..."
		case $yn in
			[yY]) sudo apt-get -y install "php$PHP_APACHE2_VERSION-fpm" >> /dev/null 2>&1 && break || echo "this version of php fpm isn't available in your depot"; exit;;
			[nN]) exit;;
			*) echo "invalid response";;
		esac
	done
fi

Execute $VERBOSE_MOD
