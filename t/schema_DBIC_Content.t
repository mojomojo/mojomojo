use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 8 );
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 0);

my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
my $root_page = $path_pages->[0];

my $root_content = $root_page->content;

isa_ok($root_content,'MojoMojo::Schema::Content','Content object can be found');
is($root_content->status,'released','root page is released');

# Warning: the following tests only work because
# we currently create no links or wanted pages in mojomojo.sql
# when we create the default db.
my @links_from = $root_page->links_from;
is_deeply(\@links_from, [], 'no links from root page yet');
my @wantedpages= $root_page->wantedpages;
is_deeply(\@wantedpages, [], 'no wanted pages from root page yet');

# Test that store_links generates the link_from and wantedpage 
# In the default content.

$root_page->content->store_links();
@wantedpages= $root_page->wantedpages;
@links_from = $root_page->links_from;

is(scalar @links_from, 1, '1 link from root page');
isa_ok($links_from[0], 'MojoMojo::Schema::Link', 'Object of correct type');
is(scalar @wantedpages, 2, '2 wanted pages from root page');
isa_ok($wantedpages[0], 'MojoMojo::Schema::WantedPage', 'Object of correct type');
