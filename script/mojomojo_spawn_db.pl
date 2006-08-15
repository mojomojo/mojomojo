#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;
#use Data::Dumper;
use YAML;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo::Schema;

my @databases      = [ qw/ MySQL SQLite PostgreSQL Oracle XML / ];
my $help           = 0;
my $dsn            = '';
my $config         = "$FindBin::Bin/../mojomojo.yml";
my $deploy         = 0;
my $create_ddl_dir = 0;
my $attrs          = {add_drop_table => 1, no_comments => 1};
my $type           = '';
my ($user, $pass);

GetOptions(
    'help|?'         => \$help,
    'dsn=s'          => \$dsn,
    'config=s'       => \$config,
    'user=s'         => \$user,
    'pass=s'         => \$pass,
    'deploy'         => \$deploy,
    'create_ddl_dir' => \$create_ddl_dir,
);
pod2usage(1) if ($help);

if (-e $config) {
    $config = YAML::LoadFile( $config );
} else {
    warn $!.' '.$config."\n";
    $config = {};
}

$dsn  ||= $config->{'Model::DBIC'}->{'connect_info'}[0];
$user ||= $config->{'Model::DBIC'}->{'connect_info'}[1];
$pass ||= $config->{'Model::DBIC'}->{'connect_info'}[2];
die "No valid Data Source Name (DSN).\n" if !$dsn;
($type) = ($dsn =~ m/:(.+?):/);
$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $db = MojoMojo::Schema->connect( $dsn, $user, $pass, $attrs );

if ($create_ddl_dir) {
    print $db->storage->create_ddl_dir($db, @databases, '0.1', "$FindBin::Bin/../db/", $attrs);
    exit (1);
}

if (!$deploy) {
    print $db->storage->deployment_statements($db, $type, undef, undef, $attrs);
    exit (1);
}

$db->storage->ensure_connected;
$db->deploy( $attrs );

$db->populate('Person', [
    [ qw/ active views photo login name email pass timezone born gender occupation industry interests movies music / ],
    [ 1,0,0,'AnonymousCoward','Anonymous Coward','','','',0,'','','','','','' ],
    [ 1,0,0,'admin','Enoch Root','','admin','',0,'','','','','','' ],
]);

$db->populate('Preference', [
    [ qw/ prefkey prefvalue / ],
    [ 'name','MojoMojo' ],
    [ 'admins','admin' ],
]);

$db->populate('PageVersion', [
    [ qw/ page version parent parent_version name name_orig depth content_version_first content_version_last 
    creator status created release_date remove_date comments/ ],
    [ 1,1,'NULL','NULL','/','/',0,1,1,1,'',0,'','','' ],
]);

$db->populate('Content', [
    [ qw/ page version creator created body status release_date remove_date type abstract version comments 
    precompiled / ],
    [ 1,1,1,0,'h1. Welcome to MojoMojo!

This is your front page. To start administrating your wiki, please log in with
username admin/password admin. At that point you will be able to set up your
configuration. If you want to play around a little with the wiki, just create
a NewPage or edit this one through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.','released','','','','',1,'','' ],
    [ 2,1,1,0,'h1. Help Index.

* Editing Pages
* Formatter Syntax.
* Using Tags
* Attachments & Photos','released','','','','',1,'','' ],
]);

$db->populate('Page', [
    [ qw/ id version parent name name_orig depth lft rgt content_version / ],
    [ 1,1,'NULL','/','/',0,1,4,1 ],
    [ 2,1,1,'help','Help',1,2,3,1 ],
]);

1;

__END__

=head1 NAME

mojomojo_spawn_db - prodcues the sql statements needed to create a MojoMojo
database

=head1 SYNOPSIS

mojomojo_spawn_db.pl -config <config-filename> [options]

 Options:
   -help              Display this help and exit
   -deploy            Deploy database schema and initial records
   -create_ddl_dir    Create SQL files for common databases in /db. Requires SQL::Translator installed.
   -dsn <dsn-string>  Use custom DSN string
   -user <username>   Database username to use when deploying
   -pass <password>   Database password to use when deploying

 config-filename must be the name of a YAML file containing connect_info for
 the database. ../mojomojo.yml is used if not specified.

 dsn-string must be a valid data source string for some DBI DBD:: module, and
 is specified overrides the string from the config file.

 Example:
    mojomojo_spawn_db.pl -dsn dbi:SQLite:mojomojo.db -deploy

 See also:
    perldoc MojoMojo

=head1 SEE ALSO

L<MojoMojo>

=head1 AUTHOR

K. J. Cheetham, C<jamie at shadowcatsystems.co.uk>

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
