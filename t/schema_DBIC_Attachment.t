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
    ? ( tests => 13 )
    : ( skip_all => 'needs DBD::SQLite and SQL::Translator for testing' ) ;
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 0);

mkdir('t/var/upload') unless -d 't/var/upload';
$schema->attachment_dir('t/var/upload');

my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
my $root_page = $path_pages->[0];

my $att = $schema->resultset("Attachment")
     ->create_from_file ( $root_page, 'bugs.jpg', 't/var/bugs.jpg' );

is(my $fn=$att->filename(),'t/var/upload/1', 'filename is correct');
ok(-f $att->filename, 'file exists');
is($att->inline_filename(),'t/var/upload/1.inline', 'inline is correct');
ok(!-f $att->inline_filename, 'inline file doesnt exist');
ok($att->photo->make_inline,'make inlinecalled ok');
ok(-f $att->inline_filename, 'inline file exists');
is($att->thumb_filename(),'t/var/upload/1.thumb', 'thumb is correct');
ok(!-f $att->thumb_filename, 'thumb file doesnt exist');
ok($att->photo->make_thumb,'make thumb called ok');
ok(-f $att->thumb_filename, 'thumb file exists');
ok($att->delete(),'Can delete app');
ok(unlink($fn));
ok(! -f $fn, 'file cleaned up ok');
