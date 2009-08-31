#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use DBD::SQLite';
    plan skip_all => 'need DBD::SQLite' if $@;

    eval 'use SQL::Translator';
    plan skip_all => 'need SQL::Translator' if $@;

    eval "use Imager";
    plan skip_all => 'need Imager' if $@;

    if (grep /^jpeg$/, Imager->read_types()) {
        plan tests => 13
    } else {
        plan skip_all => 'Imager needs JPEG support'
    }
}

use lib 't/lib';
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(populate => 1);

my $uploads_dir = 't/var/uploads';
$schema->attachment_dir($uploads_dir);  # TODO duplicate setting, in MojoMojo::Schema and in the .conf/.yml file
mkdir($uploads_dir) unless -d $uploads_dir;

my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages('/');
my $root_page = $path_pages->[0];

my $att = $schema->resultset("Attachment")
    ->create_from_file ( $root_page, 'bugs.jpg', 't/var/bugs.jpg' );

is(my $fn=$att->filename(), "$uploads_dir/1", 'filename is correct');
ok(-f $att->filename, 'file exists');
is($att->inline_filename(), "$uploads_dir/1.inline", 'inline is correct');
ok(!-f $att->inline_filename, "inline file doesn't exist");
ok($att->photo->make_inline,'make_inline called ok');
ok(-f $att->inline_filename, 'inline file exists');
is($att->thumb_filename(), "$uploads_dir/1.thumb", 'thumb filename is correct');
ok(!-f $att->thumb_filename, "thumb file doesn't exist");
ok($att->photo->make_thumb, 'make_thumb called ok');
ok(-f $att->thumb_filename, 'thumb file exists');
ok($att->delete(), 'Can delete attachment');
ok(unlink($fn), 'deleting the file from disk');
ok(! -f $fn, 'file cleaned up ok');
