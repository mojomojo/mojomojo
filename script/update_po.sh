#!/bin/sh

if [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "$0 [lang] - create/update .po file"
    exit 0
fi

if [ -z "$1" ]
then
    langs=`ls lib/MojoMojo/I18N/|grep ^..\.po$`
else
    langs=$1.po
fi

for lang in $langs ; do
    lang_=`echo $lang|sed 's/.po//'`
    echo "lang: $lang_"
    perl -Ilib `which xgettext.pl` -now -D lib -D root/forms -D root/base -P perl=* -P tt2=* -P yaml=* -P formfu=* -P text=*  -o lib/MojoMojo/I18N/$lang_.po
    perl -Ilib `which xgettext.pl` -now -D root/static -P perl=* -P tt2=* -P yaml=* -P formfu=* -P text=*  -o lib/MojoMojo/I18N/$lang_.js.po
    perl -Ilib script/po2json.pl lib/MojoMojo/I18N/$lang_.js.po root/static/json/$lang_.po.json
done
