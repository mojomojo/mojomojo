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

print "Creating initial data\n";
my @people = $schema->populate('Person', [
                                          [ qw/ active views photo login name email pass timezone born gender occupation industry interests movies music / ],
                                          [ 1,0,0,'AnonymousCoward','Anonymous Coward','','','',0,'','','','','','' ],
                                          [ 1,0,0,'admin','Enoch Root','','admin','',0,'','','','','','' ],
                                         ]);

$schema->populate('Preference', [
                                 [ qw/ prefkey prefvalue / ],
                                 [ 'name','MojoMojo' ],
                                 [ 'admins','admin' ],
                                ]);

$schema->populate('PageVersion', [
                                  [ qw/page version parent parent_version name name_orig depth
                                       content_version_first content_version_last creator status created
                                       release_date remove_date comments/ ],
                                  [ 1,1,undef,undef,'/','/',0,1,1, $people[1]->id,'',0,'','','' ],
                                 ]);

$schema->populate('Content', [
                              [ qw/ page version creator created body status release_date remove_date type abstract comments 
                                    precompiled / ],
                              [ 1,1, $people[1]->id, 0,'h1. Welcome to MojoMojo!

This is your front page. To start administrating your wiki, please log in with
username admin/password admin. At that point you will be able to set up your
configuration. If you want to play around a little with the wiki, just create
a NewPage or edit this one through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.','released','','','','','','' ],
			      [ 2,1,1,0,'h1. Help Index.

* Editing Pages
* Formatter Syntax.
* Using Tags
* Attachments & Photos','released','','','','','','' ],
                         ]);

$schema->populate('Page', [                       [ qw/ id version parent name name_orig depth lft rgt content_version / ],
                       [ 1,1,undef,'/','/',0,1,4,1 ],
                       [ 2,1,1,'help','Help',1,2,3,1 ],
                      ]);

  
print "Success!\n";
