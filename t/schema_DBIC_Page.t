#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    my $sqlite = ! $@;
    eval "use SQL::Translator";
    my $translator = ! $@;
    plan $sqlite && $translator
    ? ( tests    => 11 )
    : ( skip_all => 'needs DBD::SQLite and SQL::Translator for testing' ) ;
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 0);

my ($root_path_pages, $root_proto_pages) = $schema->resultset('Page')->path_pages('/');
my $root_path_pages_count = @$root_path_pages;
my $root_proto_pages_count = @$root_proto_pages;
is( $root_path_pages_count, 1, 'exactly 1 page returned for path "/"...' );
is( $root_proto_pages_count, 0, '...and 0 "proto" pages' );
my $root=$root_path_pages->[0];
isa_ok($root,'MojoMojo::Schema::Result::Page');

my ($child_path_pages, $child_proto_pages) = $schema->resultset('Page')->path_pages('/child/grandchild');
my $child_path_pages_count = @$child_path_pages;
my $child_proto_pages_count = @$child_proto_pages;
is( $child_path_pages_count, 1, 'exactly 1 page returned for path "/child/grandchild"...' );
is( $child_proto_pages_count, 2, '...and 2 "proto" pages for the non-existent children' );

my $person = $schema->resultset('Person')->find( 1 );
$schema->resultset('Page')->create_path_pages(
    path_pages => $child_path_pages,
    proto_pages => $child_proto_pages,
    creator => $person->id,
);

($child_path_pages, $child_proto_pages) = $schema->resultset('Page')->path_pages('/child/grandchild');
$child_path_pages_count = @$child_path_pages;
$child_proto_pages_count = @$child_proto_pages;
is( $child_path_pages_count, 3, 'now 3 pages returned for path "/child/grandchild"...' );
is( $child_proto_pages_count, 0, '...and 0 "proto" pages, after creating the missing pages' );

my @child_names = map { $_->name } @$child_path_pages;
is_deeply( \@child_names, ['/', 'child', 'grandchild'], 'new children have the correct names');

my $root_page = $root_path_pages->[0];
my @descendant_names = map { $_->name } $root_page->descendants;

{
# test tagged_descendants
    my $tag=$schema->resultset('Tag')
        ->create({tag=>'test',page=>$root->id,person=>1});
    is(scalar $root->tagged_descendants('test'),1,'Got 1 tagged descendant.');
    my $tag2=$schema->resultset('Tag')
        ->create({tag=>'test',page=>2,person=>1});
    is(scalar $root->tagged_descendants('test'),2,'Got 2 tagged descendants.');
    is(scalar $root->tagged_descendants_by_date('test'),2,'Got 2 tagged descendants.');
}
