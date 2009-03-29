#!/bin/sh

if [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "$0 [lang] - create/update .po file"
    exit 0
fi

if [ -z "$1" ]
then
    langs=`ls lib/MojoMojo/I18N/`
else
    langs=$1.po
fi

for lang in $langs ; do
    echo "lang: `echo $lang|sed 's/.po//'`"
    perl -Ilib `which xgettext.pl` -now -D lib -D root/forms -D root/base -P perl=* -P tt2=* -P yaml=* -P formfu=* -P text=*  -o lib/MojoMojo/I18N/$lang
done
