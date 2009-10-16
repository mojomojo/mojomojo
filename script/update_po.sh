#!/bin/sh

# Default setting
PERL_DEFAULT=`which perl`
MOJOMOJO_DIR="."
 
# Process command line options
while getopts ":hl:m:jp:" Option
do
	case $Option in
		# MojoMojo directory
		m )
			MOJOMOJO_DIR=$OPTARG
			;;
		# Help option
		h )
			perldoc $0
			exit
			;;
		# JOSN only
		j )
			JSON_ONLY=1
			;;
		# Language
		l )
			langs=$OPTARG
			;;
		# perl path
		p )
			PERL=$OPTARG
			;;
		# Unknow option
		* ) 
			echo Unknow option. 
			echo See:
			echo "   ./$0 -h"
			echo for usage
			exit 1
			;;
	esac
done

# Check perl executable
if [ -z "$PERL" ] || [ ! -x "$PERL" ]; then
	PERL=$PERL_DEFAULT
fi

# Check MojoMojo dir
if [ ! -d "$MOJOMOJO_DIR/lib/MojoMojo/I18N" ]; then
	echo "$MOJOMOJO_DIR directory: lib/MojoMojo/I18N not found."
	exit 1
else
	cd $MOJOMOJO_DIR
	MOJOMOJO_DIR="."
fi

# Check language(s)
if [ -z "$langs" ]
then
	langs=$(ls $MOJOMOJO_DIR/lib/MojoMojo/I18N|grep ^..\.po$)
else
	langs=$langs.po
fi

# Process .po files
for lang in $langs ; do
	lang_=`echo $lang|sed 's/.po//'`
	echo "lang: $lang_"
	if [ -z "$JSON_ONLY" ]; then
		$PERL -Ilib `which xgettext.pl` -now -D $MOJOMOJO_DIR/lib/MojoMojo -D $MOJOMOJO_DIR/root/forms -D $MOJOMOJO_DIR/root/base -P perl=* -P tt2=* -P yaml=* -P formfu=* -P text=* -o $MOJOMOJO_DIR/lib/MojoMojo/I18N/$lang_.po
		$PERL -Ilib `which xgettext.pl` -now -D $MOJOMOJO_DIR/root/static/js -P perl=* -P tt2=* -P yaml=* -P formfu=* -P text=* 	-o $MOJOMOJO_DIR/lib/MojoMojo/I18N/$lang_.js.po
	fi
	$PERL -Ilib $MOJOMOJO_DIR/script/po2json.pl $MOJOMOJO_DIR/lib/MojoMojo/I18N/$lang_.js.po $MOJOMOJO_DIR/root/static/json/$lang_.po.json
done

# All is OK
exit 0

<<PODUSAGE

=pod

=head1 NAME

update_po.sh - create or update .po file

=head1 SYNOPSIS

   %> update_po.sh [command] [options]

=head1 DESCRIPTION

F<update_po.sh> is a shell script that lets you to create or update .po file.

=head1 ARGUMENTS

=over 4

=item * C<-l> I<language>

.po langunage file. Default to all existing .po files. 

=item * C<-m> I<path>

MojoMojo directory. 

=back

=head1 OPTIONS

=over 4


=item * C<-p> I<path>

perl binary executable path. You can also set C<PERL> environment variable. 
For example: 

   %> PERL=/path/to/my/perl ./update_po.sh ...

=item * C<-j>

Create json file only.

=item * C<-h>

Print out this help page and exit.

=back

=head1 EXAMPLES

   %> sh update_po.sh 

   %> sh update_po.sh -l it -p /path/to/perl-5.11/bin/perl
   
   %> sh update_po.sh -m /my/lib/MoyoMoyo -l de

=head1 AUTHOR

Robert Litwiniec (basic script)
Enrico Sorcinelli (script improvements and POD)

=head1 BUGS

Send bug reports and comments to: <...>.
In each report please include the version module, the Perl version, the Apache,
the mod_perl version and your SO. If the problem is  browser dependent please
include also browser name and version.

=head1 SEE ALSO

MojoMojo

=head1 COPYRIGHT

MojoMojo team,

=cut

PODUSAGE
