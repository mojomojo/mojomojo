#!/usr/bin/env perl
 
=head1 NAME

mojomojo_update_db.pl - DBIC versioning

=head1 AUTHOR

dab

=head1 DESCRIPTION

DBIx Versionning see on catapulse.org http://www.catapulse.org/articles/view/75

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo::Schema;
use Config::JFDI;
use Term::Prompt;

my $jfdi = Config::JFDI->new(name => "MojoMojo");
my $config = $jfdi->get;

my ($dsn, $user, $pass) = @ARGV;
eval {
    if (!$dsn) {
        ($dsn, $user, $pass) =
          @{$config->{'Model::DBIC'}->{'connect_info'}};
    };
};
if($@){
    die "Your DSN line in mojomojo.conf doesn't look like a valid DSN.".
      "  Add one, or pass it on the command line.";
}
die "No valid Data Source Name (DSN).\n" if !$dsn;
$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $version = MojoMojo::Schema->VERSION;

my $schema  = MojoMojo::Schema->connect($dsn, $user, $pass) or 
  die "Failed to connect to database";


$schema->create_ddl_dir(
    ['SQLite'],
    $version > 1 ? $version : undef,
    'db/upgrades',
    $version ? $version-1 : $version
);


