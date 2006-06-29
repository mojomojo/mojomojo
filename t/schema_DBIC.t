use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 3 );
}

use lib qw(t/lib);

use_ok( 'MojoMojoTestSchema' );

ok( my $schema = MojoMojoTestSchema->init_schema(no_populate => 1), 'created test schema object' );
my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
is( $path_pages->[0]->name, '/', 'retrieved the root page' );
