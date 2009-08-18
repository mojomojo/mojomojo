use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Getopt::Long;

=head1 Description

EXPERIMENTAL Global Search and Replace for MojoMojo pages.
This script will search and replace on the most recent version of all pages.
It has NOT been thorougly tested yet.  Use at your own risk.

=head1 Usage

General Form:
  perl script/util/search_and_replace.pl --search 'something'  --replace 'something else'

Concrete Example:
  perl script/util/search_and_replace.pl --search 'Cata\sliscious' --replace 'Dog man was here.'

The concrete example will replace 'Cata liscious' with 'Dog man was here.'
Note the use of \s to match a space in the search term.

=cut

my $search_string;
my $replacement_string;
my $result = GetOptions(
    "search|s=s"  => \$search_string,
    "replace|r=s" => \$replacement_string,
) or die &usage();

# parametres fourni ?
if ( !$search_string || !$replacement_string ) {
    &usage;
    exit 1;
}

use MojoMojo;
use MojoMojo::Schema;
use Data::Dumper;

my $schema  = schema_connect();
my $page_rs = $schema->resultset('Page');

my $found_search_string = 0;
while ( my $page = $page_rs->next ) {
    
    # This is for the lastest content version of a page.
    my $page_content = $schema->resultset('Content')->search(
        {
            page    => $page->id,
            version => $page->content_version,
        }
    );
    if ( $page_content->count == 1 ) {
        my $content = $page_content->first->body;

        # Search on something
        if ( $content =~ m{$search_string} ) {
            my $number_of_replacements =
              $content =~ s{$search_string}{$replacement_string}mxg;
            $number_of_replacements ||= 0;
            print "Made $number_of_replacements replacments in page: ",
              $page->name_orig, " \n";
            
            if ( $number_of_replacements ) { $found_search_string = 1; }
            # Give the adulterated content back to db.
            $page_content->first->update( { body => $content } );
        }
    }
    elsif ( $page_content->count > 1 ) {
        print "ERROR: Seems there is more than one 'latest content version' of
the page: ", $page->name, "\n";
    }
    else {

        # This case happens when a page is only in prototype form. In other
        # words, it is a node with children that has never received content
        # of it's own.
        print "NOTICE: Page ", $page->name,
          " is only a prototype and therefore has no content.\n";
    }
}
if ( not $found_search_string ) { print "Did not find search string: $search_string\n"; }

sub schema_connect {
    my @db_cfg = @{ MojoMojo->config()->{'Model::DBIC'}->{'connect_info'} };

    return MojoMojo::Schema->connect( @db_cfg[qw/0 1 2/] );
}

sub usage {
    print "Usage:
  perl script/util/search_and_replace.pl --search=SEARCH_STRING --replace=REPLACEMENT_STRING\n";
}
