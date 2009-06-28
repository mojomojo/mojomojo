#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_DEBUG} = 0 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use MojoMojo::Schema;
use Config::JFDI;
#use Term::Prompt;
use  MojoMojo::Formatter::File;
use Path::Class ();
use Getopt::Long;

my($DIR, $URL_DIR, $debug, $help);
GetOptions (  'dir=s'        => \$DIR,
              'urlbase=s'    => \$URL_DIR,
              'debug'         => \$debug,
              'help'          => \$help ) or die &Usage;


$debug=0 if ( ! $debug);

# parametres fourni ?
if ( $help || ! $DIR || ! $URL_DIR ){
  &Usage;
  exit 1;
}

$URL_DIR = "$URL_DIR/";

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

my $person = $schema->resultset('Person')->find( 1 );





# Walk in $DIR
my $rootdir = Path::Class::dir($DIR);
my @files;
my $body;
my $urlpage;
$rootdir->recurse(callback => sub {
            my ($entry) = @_;
            push @files, $entry unless ( $entry eq $DIR );
        });


createpage($URL_DIR, "{{dir $DIR}}", $person);

foreach my $f (@files){

  $urlpage = $f;
  $urlpage =~ s/$DIR//;
  $urlpage =~ s/\./_/;
  $urlpage = $URL_DIR . $urlpage;

  if ( ref $f eq 'Path::Class::Dir'){
    $body = "{{dir $f}}";
  }
  else{
    my $plugin   = MojoMojo::Formatter::File->plugin($f);

    if ( $plugin ){
      $body = "{{file $plugin $f}}";
    }
    else {
      print STDERR "Can't find plugin for $f !!!\n";
      $body = "{{file UNKOWN_PLUGIN $f}}";
    }
  }

  createpage($urlpage,$body, $person);
}
exit 0;






# update the search index with the new content
#$schema->resultset('Page')->set_paths($page);

#my $search=MojoMojo::Model::Search->new;
#$search->index_page($page);



sub createpage{
  my ($url, $body, $person) = @_;


  my ($path_pages, $proto_pages) = $schema->resultset('Page')->path_pages($url);

  $path_pages = $schema->resultset('Page')->create_path_pages(
    path_pages => $path_pages,
    proto_pages => $proto_pages,
    creator => $person->id,
  );

  my $page = $path_pages->[ @$path_pages - 1 ];

  my %content;
  $content{creator} = $person->id;
  $content{body}    = $body;


  $page->update_content(%content);
  $schema->resultset('Page')->set_paths($page);
  print "$url done\n";
}


#-----------------------------------------------------------------------------#
# Usage
#-----------------------------------------------------------------------------#
sub Usage{
  print "$0 --dir=DIRECTORY --url=URLBASE [--debug] [--help]\n";
}
