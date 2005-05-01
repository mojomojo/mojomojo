#!/usr/bin/perl -w

use strict;
use DBI;
use Getopt::Long;
use Pod::Usage;

my $help = 0;
my $dsn;
my $sql;
my $user;
my $pass;

GetOptions
(
 'help|?' => \$help,
 'dsn=s'  => \$dsn,
 'sql=s'  => \$sql,
 'user:s' => \$user,
 'pass:s' => \$pass,
);
pod2usage(1) if ($help || !$dsn || !$sql);

my $dbh = DBI->connect($dsn, $user, $pass, {RaiseError => 1} )
    or die $DBI::errstr;
open my $SQL, '<', $sql
    or die "Cannot open sql file $sql: $!";

$/ = ';';

$dbh->do($_) while (<$SQL>);

1;
__END__

=head1 NAME

mojomojo_create_db - execute a file of sql statements to create a MojoMojo database

=head1 SYNOPSIS

mojomojo_create_db.pl -dsn <dsn-string> -sql <sql-filename> [options]

 Options:
   -help             display this help and exit
   -user <username>  database username
   -pass <password>  database user's password

 dsn-string must be a valid data source string for some DBI DBD:: module

 sql-filename must be the name of a file containing sql statements to create a MojoMojo database

 Example:
    mojomojo_create_db.pl -dsn dbi:SQLite2:mojomojo.db -sql mojomojo.sql

 See also:
    perldoc MojoMojo

=head1 DESCRIPTION

mojomojo_create_db.pl exists mostly for SQLite. Since the SQLite RDBMS is
embedded into DBD::SQLite, many users use DBI::Shell for command line
batch processing. However, DBI::Shell does not properly escape some
literal characters we need for MojoMojo, specifically '/'. Also, this
script very simplistically finds sql statements by splitting input
on ';', so it may fail if any comments contain these characters.

=head1 SEE ALSO

L<MojoMojo>

=head1 AUTHOR

David Naughton, C<naughton@umn.edu>

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
