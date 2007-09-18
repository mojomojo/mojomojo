use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    my $sqlite = ! $@;
    eval "use SQL::Translator";
    my $translator = ! $@;
    plan $sqlite && $translator
    ? ( tests => 5 )
    : ( skip_all => 'needs DBD::SQLite and SQL::Translator for testing' ) ;
}

use lib qw(t/lib);
use_ok( 'MojoMojoTestSchema' );


ok( my $schema = MojoMojoTestSchema->init_schema(no_populate => 0), 'created a test schema object' );

my $person = $schema->resultset('Person')->find(1);
like( $person->login, qr/\w+/, 'retrieved the default user' );

my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
my $page = $path_pages->[0];
is( $page->name, '/', 'retrieved the root page' );

my $content = $page->content;
like( $content->body, qr/\w+/, 'retrieved the root page content' );

