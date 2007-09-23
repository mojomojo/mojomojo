#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

BEGIN { $ENV{CATALYST_DEBUG} = 0 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use MojoMojo::Schema;
use Config::General;




my $cfg = Config::General->new("$Bin/../mojomojo.conf");
my $config =  { $cfg->getall };

my ($dsn, $user, $pass) = @ARGV;
eval {
    if (!$dsn) {
        ($dsn, $user, $pass) =
          @{$config->{'Model::DBIC'}->{'connect_info'}};
    };
};
if($@){
    die "Your DSN line in mojomojo.yml doesn't look like a valid DSN.".
      "  Add one, or pass it on the command line.";
}
die "No valid Data Source Name (DSN).\n" if !$dsn;
$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $schema = MojoMojo::Schema->connect($dsn, $user, $pass) or 
  die "Failed to connect to database";

print "Deploying schema to $dsn\n";
$schema->deploy;

$schema->create_initial_data();