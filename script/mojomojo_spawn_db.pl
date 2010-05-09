#!/usr/bin/env perl

=head1 NAME

mojomojo_spawn_db.pl - hash plain text passwords

=head1 AUTHOR

Jonathan Rockway <jrockway@cpan.org>

=head1 COPYRIGHT

2007 Jonathan Rockway <jrockway@cpan.org>

=cut

BEGIN { $ENV{CATALYST_DEBUG} = 0 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use MojoMojo::Schema;
use Config::JFDI;
use Getopt::Long;

my $jfdi   = Config::JFDI->new(name => "MojoMojo");
my $config = $jfdi->get;

my ($dsn, $user, $password, $unicode_option);

my $default_user = $ENV{USER} || 'unknown';
my %opts = (
    wiki_name       => $config->{name},
    admin_username  => 'admin',
    admin_password  => 'admin',
    admin_fullname  => $default_user,
    admin_email     => "$default_user\@localhost",
    anonymous_email => 'anonymous.coward@localhost',
);

my $help;
GetOptions(
    'help'             => \$help,
    'dsn:s'            => \$dsn,
    'db-user:s'        => \$user,
    'db-password:s'    => \$password,
    'wiki:s'           => \$opts{wiki_name},
    'admin-username:s' => \$opts{admin_username},
    'admin-password:s' => \$opts{admin_password},
    'admin-fullname:s' => \$opts{admin_fullname},
    'admin-email:s'    => \$opts{admin_email},
    'anon-email:s'     => \$opts{anonymous_email},
);

if ($help) {
    print <<"EOF";

mojomojo_spawn_db.pl ...

This script looks in the mojomojo.conf file for database connection
info if none is passed on the command line. Set the MOJOMOJO_CONFIG
environment variable to tell it where the file is.

Accepts the following options:

  --dsn              Default taken from mojomojo.conf
  --db-user          Default taken from mojomojo.conf
  --db-password      Default taken from mojomojo.conf
  --wiki             Wiki name, default taken from mojomojo.conf
  --admin-username   Admin username, default is admin
  --admin-password   Admin password, default is admin
  --admin-fullname   Admin name, default is $default_user
  --admin-email      Admin email address, default is $default_user\@localhost
  --anon-email       Anon user email address, default is anonymous.coward\@localhost

EOF

    exit;
}


eval {
    if (!$dsn)
    {
        if (ref $config->{'Model::DBIC'}->{'connect_info'}) {
            $dsn  = $config->{'Model::DBIC'}->{'connect_info'}->{dsn};
            $user = $config->{'Model::DBIC'}->{'connect_info'}->{user};
            $password = $config->{'Model::DBIC'}->{'connect_info'}->{password};

            # Determine database type amongst: SQLite, Pg or MySQL
            my $db_type = lc($dsn =~ m/^dbi:(\w+)/);
            my %unicode_connection_for_db = (
                'sqlite' => { sqlite_unicode    => 1 },
                'pg'     => { pg_enable_utf8    => 1 },
                'mysql'  => { mysql_enable_utf8 => 1 },
            );
            $unicode_option = $unicode_connection_for_db{$db_type};
        }
        else {
            $dsn = $config->{'Model::DBIC'}->{'connect_info'};
        }
    }
};
if ($@) {
    die "Your DSN line in mojomojo.conf doesn't look like a valid DSN."
      . "  Add one, or pass it on the command line.";
}
die "No valid Data Source Name (DSN).\n" if !$dsn;
$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $schema = MojoMojo::Schema->connect($dsn, $user, $password, $unicode_option)
  or die "Failed to connect to database";

# Check if database is already deployed by
# examining if the table Person exists and has a record.
eval { $schema->resultset('MojoMojo::Schema::Result::Person')->count };
if (!$@) {
    die "You have already deployed your database\n";
}

print <<"EOF";

Creating a new wiki ...

  dsn:            $dsn
  wiki name:      $opts{wiki_name}
  admin username: $opts{admin_username}
  admin password: $opts{admin_password}
  admin name:     $opts{admin_fullname}
  admin email:    $opts{admin_email}
  anon email:     $opts{anonymous_email}

EOF

print "Deploying schema to $dsn\n";
$schema->deploy;

$schema->create_initial_data($config, \%opts);
