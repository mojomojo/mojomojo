use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    my $sqlite = ! $@;
    eval "use SQL::Translator";
    my $translator = ! $@;
    plan $sqlite && $translator
    ? ( tests => 1 )
    : ( skip_all => 'needs DBD::SQLite and SQL::Translator for testing' ) ;
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 1);

is(ref $schema->resultset('Person')->registration_profile,'HASH');
