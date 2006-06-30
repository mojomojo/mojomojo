use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 1 );
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 1);

my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
my $root_page = $path_pages->[0];

#my $root_content = $root_page->content;

# Warning: the following tests only work because
# we currently create no links or wanted pages in mojomojo.sql
# when we create the default db.
my @links_from = $root_page->links_from;
is_deeply(\@links_from, [], 'no links from root page yet');

