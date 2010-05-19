#!/usr/bin/env perl
=head1 NAME

import_content.pl - import content from a file into a MojoMojo page

=head1 SYNOPSIS

    script/util/import_content.pl /path/to/page page.markdown

Since this operation is undoable, the script will prompt you to confirm that
you really want to replace the contents of the last version of /path/to/page
with what's in F<page.markdown>.

=head1 DESCRIPTION

Replace the contents of the last version of a page with the content from a
file. Useful if you want to fix a typo in a page without bumping the version
and creating yet another revision in the database. Of course, can be used for
evil, but then so could be a series of SQL commands.

=head1 AUTHORS

Dan Dascalescu (dandv), http://dandascalescu.com

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=head1 COPYRIGHT

Copyright (C) 2010, Dan Dascalescu.

=cut

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use MojoMojo::Schema;

=head2 preview

Return the middle of a string. Examples:

    preview('abcdefghijk', 10)
            'ab [...] k'
            
    preview('abcdefghijkl', 10), "\n";
            'ab [...] l'
            
    preview('abcdefghijkl', 11), "\n";
            'ab [...] kl'
            
    preview('abcdefghijklm', 10), "\n";
            'ab [...] m'

    preview('abcdef0000000000ghijklm', 10), "\n";
            'ab [...] m'

=cut

sub preview {
    my ($string, $limit) = @_;
    my $length = length $string;
    return $string if $length <= $limit;
    my $middle = ' [...] ';
    return 
        substr( $string, 0, ($limit+1 - length $middle)/2 )
      . $middle
      . substr( $string, $length - ($limit-1 - length $middle)/2 )
    ;   
}


my ($page_path, $filename_content, $dsn, $user, $pass) = @ARGV;

if (!$page_path) {
    die "USAGE: $0 /path/to/page filename [dsn user pass]
Replace the contents of the last version of a page with the content from a file
\n";
}

if (!$dsn) {
    # no DSN passed via the command line; attempting to read one from the config file
    require Config::JFDI;
    
    my $config = Config::JFDI->new(name => "MojoMojo")->get;
    die "Couldn't read config file" if not keys %{$config};
    
    eval {
        if (ref $config->{'Model::DBIC'}->{'connect_info'}) {
            $dsn  = $config->{'Model::DBIC'}->{'connect_info'}->{dsn};
            $user = $config->{'Model::DBIC'}->{'connect_info'}->{user};
            $pass = $config->{'Model::DBIC'}->{'connect_info'}->{password};
        } else {
            ($dsn, $user, $pass) = @{$config->{'Model::DBIC'}->{connect_info}};
        }
    };
    die "Your DSN settings in mojomojo.conf seem invalid\n" if $@;
}    
die "Couldn't find a valid Data Source Name (DSN).\n" if !$dsn;

$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $schema = MojoMojo::Schema->connect($dsn, $user, $pass) or
  die "Failed to connect to database";

my ( $path_pages, $proto_pages ) = $schema->resultset('Page')->path_pages( $page_path )
    or die "Can't find page $page_path\n";

if (scalar @$proto_pages) {
    die "One or more pages at the end do(es) not exist: ",
        (join ", ", map { $_->{name_orig} } @$proto_pages),
        "\n";
}

# Get the lastest content version of the page
my $page = $path_pages->[-1];
my $page_content_rs = $schema->resultset('Content')->search(
    {
        page    => $page->id,
        version => $page->content_version,
    }
);
die "More than one 'last version' for page <$page_path>. The database may be corrupt.\n"
    if $page_content_rs->count > 1;
my $page_content = $page_content_rs->first;    

open my $file_content, '<:utf8', $filename_content or die $!;
my $content; {local $/; $content = <$file_content>};

print "Are you sure you want to replace\n",
    preview($page_content->body, 300),
    "\nwith\n",
    preview($content, 300),
    "\n? ('yes'/anything else): ";
my $answer = <STDIN>; chomp $answer;
if ($answer eq 'yes') {
    $page_content->update( 
        { 
            body => $content,
            precompiled => '',  # this needs to be blanked so that MojoMojo will re-compile it
        }
    );
    print "Done.\n";
} else {
    print "Aborted.\n";
    exit 1;
}
