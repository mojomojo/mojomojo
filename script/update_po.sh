#!/bin/sh

if [ ! -z "$1" ]
then
    echo "lang: $1"
    perl -Ilib `which xgettext.pl` -D lib -D root -o lib/MojoMojo/I18N/$1.po
else
    for i in 'en' 'de' 'fr' 'ja' 'no' 'ca' 'es' 'pl' ; do
        echo "lang: $i"
        perl -Ilib `which xgettext.pl` -D lib -D root -o lib/MojoMojo/I18N/$i.po
    done
fi
