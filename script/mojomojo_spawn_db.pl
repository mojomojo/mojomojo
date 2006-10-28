#!/usr/bin/perl
# kt_timeline_spawndb.pl 
# Copyright (c) 2006 Jonathan Rockway <jrockway@cpan.org> 
# Copied from older mojomojo_spawndb.pl by K. J. Cheetham <jamie@shadowcatsystems.co.uk> 
# Perl license.

use warnings;
use strict;
use DateTime;
use Getopt::Long;
use Pod::Usage;
use Path::Class;
use Config::Any;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo::Schema;
use YAML;

my @databases      = [ qw/ MySQL SQLite PostgreSQL Oracle XML YAML / ];
my $help           = 0;
my $bin            = dir($FindBin::Bin);
my $config         = YAML::LoadFile(file($bin->parent, 'mojomojo.yml'));
my $deploy         = 0;
my $create_ddl_dir = 0;
my $attrs          = {add_drop_table => 1, no_comments => 1};
my $type           = '';


my ($user, $pass, $dsn);
GetOptions('help|?'         => \$help,
	   'dsn=s'          => \$dsn,
	   'user=s'         => \$user,
	   'pass=s'         => \$pass,
	   'deploy'         => \$deploy,
	   'create_ddl_dir' => \$create_ddl_dir,
	  );

pod2usage(1) if ($help);

my $config_dsn;
eval { 
    ($config_dsn, $user, $pass) = 
      @{$config->{'Model::DBIC'}->{'connect_info'}};
};
if($@){
    die "Your DSN line in mojomojo.yml doesn't look like a valid DSN."
}
$dsn = $config_dsn if(!$dsn);
die "No valid Data Source Name (DSN).\n" if !$dsn;

($type) = ($dsn =~ m/:(.+?):/);
$type = 'MySQL' if $type eq 'mysql';

$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $db = MojoMojo::Schema->connect($dsn, $user, $pass, $attrs);
if ($create_ddl_dir) {
    print $db->storage->create_ddl_dir($db, @databases, '0.1', 
				       "$FindBin::Bin/../db/", $attrs);
}
else {
    print "Connecting to $dsn\n";
    print " as $user\n" if $user;
    print " with password\n" if $pass;
    $db->storage->ensure_connected;
    $db->deploy( $attrs );

    my @people = $db->populate('Person', [
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
				  [ qw/page version parent parent_version name name_orig depth
				       content_version_first content_version_last creator status created
				       release_date remove_date comments/ ],
				  [ 1,1,undef,undef,'/','/',0,1,1, $people[1]->id,'',0,'','','' ],
				 ]);
    
    $db->populate('Content', [
			      [ qw/ page version creator created body status release_date remove_date type abstract version comments 
				    precompiled / ],
			      [ 1,1, $people[1]->id, 0,'h1. Welcome to MojoMojo!

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
			   [ 1,1,undef,'/','/',0,1,4,1 ],
			   [ 2,1,1,'help','Help',1,2,3,1 ],
			  ]);
}

1;

__END__

=head1 NAME

mojomojo_spawn_db - prodcues the sql statements needed to create a MojoMojo
database

=head1 SYNOPSIS

mojomojo_spawndb.pl [options]

 Options:
   -help              Display this help and exit
   -create_ddl_dir    Create SQL files for common databases in /db. 
                      Requires SQL::Translator installed.
 Example:
    mojomojo_spawndb.pl

 See also:
    perldoc MojoMojo

=head1 SEE ALSO

L<MojoMojo>

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
