#!/bin/sh

if [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "$0 [lang] - create/update .po file"
    exit 0
fi

if [ ! -z "$1" ]
then
    echo "lang: $1"
    perl -Ilib `which xgettext.pl` -D lib -D root/forms -D root/base -o lib/MojoMojo/I18N/$1.po
else
    for i in `ls lib/MojoMojo/I18N` ; do
        echo "lang: `echo $i|sed 's/.po//'`"
        perl -Ilib `which xgettext.pl` -D lib -D root/forms -D root/base -o lib/MojoMojo/I18N/$i
    done
fi
