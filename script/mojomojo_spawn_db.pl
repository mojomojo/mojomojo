#!/usr/bin/env perl
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>

BEGIN { $ENV{CATALYST_DEBUG} = 0 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
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

my $schema = MojoMojo::Schema->connect($dsn, $user, $pass) or 
  die "Failed to connect to database";

print "It's time to set some default values:\n";

my $default_user = $ENV{USER} || 'unknown';

my %custom_values = (
    wiki_name       => prompt( 'x', 'Name of the wiki?',                     '', 'MojoMojo' ),
    admin_username  => prompt( 'x', 'Username of the admin user?',           '', 'admin' ),
    admin_password  => prompt( 'x', 'Password of the admin user?',           '', 'admin' ),
    admin_fullname  => prompt( 'x', 'Full name of the admin user?',          '', $default_user ),
    admin_email     => prompt( 'x', 'E-Mail address of the admin user?',     '', "$default_user\@localhost" ),
    anonymous_email => prompt( 'x', 'E-Mail address of the Anonymous user?', '', 'anonymous.coward@localhost' ),
);

print "Deploying schema to $dsn\n";
$schema->deploy;

$schema->create_initial_data($config, \%custom_values);
