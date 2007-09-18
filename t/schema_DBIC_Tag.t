use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    my $sqlite = ! $@;
    eval "use SQL::Translator";
    my $translator = ! $@;
    plan $sqlite && $translator
    ? ( tests => 4 )
    : ( skip_all => 'needs DBD::SQLite and SQL::Translator for testing' ) ;
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 0);
my ($page_ref) = $schema->resultset('Page')->path_pages('/');
my $page=$page_ref->[0];
is(scalar $page->tags,0,'no tags for root page');
my $tag=$schema->resultset('Tag')
    ->create({tag=>'test',page=>$page->id,person=>1});
is(scalar $page->tags,1,'added 1 to the root page');
my $tag2=$schema->resultset('Tag')
    ->create({tag=>'test2',page=>$page->id,person=>1});
is($schema->resultset('Tag')->most_used()->count(),2);
my $tag3=$schema->resultset('Tag')
    ->create({tag=>'test3',page=>$page->id,person=>1});
is($schema->resultset('Tag')->by_page($page->id)->count(),3);
