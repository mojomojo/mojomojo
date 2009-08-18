#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use DBD::SQLite';
    plan skip_all => 'need DBD::SQLite' if $@;

    eval 'use SQL::Translator';
    plan skip_all => 'need SQL::Translator' if $@;

    plan tests => 4;
}

use lib 't/lib';
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(populate => 1);
my ($page_ref) = $schema->resultset('Page')->path_pages('/');
my $page = $page_ref->[0];
is(scalar $page->tags, 0, 'no tags for root page');

my $tag = $schema->resultset('Tag')->create({
    tag => 'test',
    page => $page->id,
    person => 1
});
is(scalar $page->tags, 1, 'added 1 to the root page');

my $tag2 = $schema->resultset('Tag')->create({
    tag => 'test2',
    page => $page->id,
    person => 1
});
is($schema->resultset('Tag')->most_used()->count(), 2, 'added one more, 2 now');

my $tag3 = $schema->resultset('Tag')->create({
    tag => 'test3',
    page => $page->id,
    person => 1
});
is($schema->resultset('Tag')->by_page($page->id)->count(), 3, 'added one more, 3 now');
