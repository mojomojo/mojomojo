#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use DBD::SQLite';
    plan skip_all => 'need DBD::SQLite' if $@;

    eval 'use SQL::Translator';
    plan skip_all => 'need SQL::Translator' if $@;

    plan tests => 1;
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 1);

is(ref $schema->resultset('Person')->registration_profile,'HASH');
