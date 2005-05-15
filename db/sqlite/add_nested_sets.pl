#!/usr/bin/perl -w

# add_nested_sets.pl

use strict;
use Getopt::Long;
use Pod::Usage;
use File::Copy;
use Class::DBI::Loader;
use DBI;

my $help = 0;

GetOptions( 'help|?' => \$help );

pod2usage(1) if $help;

my $db_file = shift;
my $backup_db_file = shift;

$db_file ||= 'mojomojo.db';
pod2usage(1) unless -f $db_file;
unless ((defined $backup_db_file) && -f $backup_db_file)
{
    $backup_db_file = $db_file . '.bak';
    copy($db_file, $backup_db_file)
	or die "Could not create backup databse: $!";
}

# backup db

my $backup_loader = Class::DBI::Loader->new(
 dsn       => "dbi:SQLite:$backup_db_file",
 namespace => 'MojoMojoDB_Backup',
 additional_classes => 'Class::DBI::AbstractSearch',
 relationships => 1,
);
my $backup_pages = $backup_loader->find_class('page');

# new db

my $dbh = DBI->connect( "dbi:SQLite:$db_file" );
$dbh->do('DROP TABLE page');

$dbh->do(<<'');
CREATE TABLE page (
 id              INTEGER PRIMARY KEY,
 version         INTEGER,
 parent          INTEGER REFERENCES page,
 name            VARCHAR(200),
 name_orig       VARCHAR(200),
 depth           INTEGER,
 lft             INTEGER,
 rgt             INTEGER,
 content_version INTEGER,
 FOREIGN KEY (id, content_version) REFERENCES content (page, version),
 FOREIGN KEY (id, version) REFERENCES page_version (page, version)
)

# all children of a parent must have unique names:
$dbh->do(<<'');
CREATE UNIQUE INDEX page_unique_child_index ON page (parent, name)

# we resolve paths by searching on page name and depth, so:
$dbh->do(<<'');
CREATE INDEX page_depth_index ON page (depth, name)

# we also resolve paths with nested sets:
$dbh->do(<<'');
CREATE INDEX page_lft_index ON page (lft)

$dbh->do(<<'');
CREATE INDEX page_rgt_index ON page (rgt)

$dbh->disconnect;

my $loader = Class::DBI::Loader->new(
 dsn       => "dbi:SQLite:$db_file",
 namespace => 'MojoMojoDB',
 additional_classes => 'Class::DBI::AbstractSearch',
 relationships => 1,
);

my $pages = $loader->find_class('page');

# main loop:

my $parent = 'IS NULL';
my $lr_number = 0;

my $new_lr_number = add_lr_numbers( $parent, $lr_number );
exit;

sub add_lr_numbers
{
    my ($parent, $lr_number) = @_;

    # we cheat a bit here, since no page has more than one version yet
    my @backup_pages = $backup_pages->search_where
	(
	 {parent   => ($parent eq 'IS NULL' ? \$parent : $parent)},
	 {order_by => 'name'},
	);
    for my $backup_page (@backup_pages)
    {
        my %page_data
            = map { $_ => (ref $backup_page->$_ ? $backup_page->$_->id : $backup_page->$_) }
                $backup_pages->columns;
        my $page = $pages->create( \%page_data );

        print "\n" . $page->name . ", depth " . $page->depth . "\n";
        $lr_number++;
        $page->lft( $lr_number );
        print "lft = $lr_number\n";

        $lr_number = add_lr_numbers( $page->id, $lr_number );

        print "\n" . $page->name . ", depth " . $page->depth . "\n";
        $lr_number++;
        $page->rgt( $lr_number );
        print "rgt = $lr_number\n";

        $page->update;
    }
    return $lr_number;
}

=head1 NAME

add_nested_sets - adds nested set C<lft>, C<rgt> columns and values to the page table of a sqlite mojomojo database

=head1 SYNOPSIS

add_nested_sets.pl [-help | <db-file> [<backup-db-file>]]

 Examples:
    add_nested_sets.pl -help
    add_nested_sets.pl mojomojo.db
    add_nested_sets.pl mojomojo.db mojomojo.db.bak
    add_nested_sets.pl # assumes the filenames above. creates mojomojo.db.bak if necessary

 See also:
    perldoc MojoMojo

=head1 DESCRIPTION

Only those who have already-existing sqlite databases without page.(lft|rgt) columns will need to
run this script. Since this is a simple script that will be needed only temporarily by just a few
people, it doesn't have much error handling. Make sure you have backups!

=head1 AUTHOR

David Naughton, C<naughton\@umn.edu>

=head1 COPYRIGHT

Copyright 2005 David Naughton. All rights reserved.

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
