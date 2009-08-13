#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use DBD::SQLite';
    plan skip_all => 'need DBD::SQLite' if $@;

    eval 'use SQL::Translator';
    plan skip_all => 'need SQL::Translator' if $@;

    plan tests => 5;
}

use lib 't/lib';
use_ok( 'MojoMojoTestSchema' );


ok( my $schema = MojoMojoTestSchema->init_schema(populate => 1), 'created a test schema object' );

my $person = $schema->resultset('Person')->find(1);
like( $person->login, qr/\w+/, 'retrieved the default user' );

my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
my $page = $path_pages->[0];
is( $page->name, '/', 'retrieved the root page' );

my $content = $page->content;
like( $content->body, qr/\w+/, 'retrieved the root page content' );
