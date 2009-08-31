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

my $schema = MojoMojoTestSchema->init_schema(populate => 1);

my $admin=$schema->resultset('Person')->get_person('admin');
isa_ok($admin ,'MojoMojo::Schema::Result::Person'); 
