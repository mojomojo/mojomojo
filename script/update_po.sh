#!/bin/sh

#find lib root script -type f -not -path '*.svn*' \( -name '*.pm' -or -name '*.tt' -or -name '*.js' -or -name '*.yml' \) > filelist.tmp

    for i in 'en' 'no' 'de' 'fr' 'ja' ; do
    echo "lang: $i"
	  perl -Ilib /usr/bin/xgettext.pl -D lib -D root -o lib/MojoMojo/I18N/$i.po
done;

