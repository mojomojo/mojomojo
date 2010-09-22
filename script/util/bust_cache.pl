#!/usr/bin/env perl
=head1 NAME

bust_cache.pl - Delete the precompiled content of a page. MojoMojo
will recompile the page next time it is requested.

=head1 SYNOPSIS

    script/util/bust_cache.pl /path/to/page

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

my ($page_path, $filename_content, $dsn, $user, $pass) = @ARGV;

if (!$page_path) {
    die "USAGE: $0 /path/to/page [dsn user pass]
Delete the precompiled content of a page. MojoMojo
will recompile the page next time it is requested.
\n";
}

if (!$dsn) {
    # no DSN passed via the command line; attempting to read one from the config file
    require Config::JFDI;
    
    my $config = Config::JFDI->new(name => "MojoMojo")->get;
    die "Couldn't read config file" if not keys %{$config};
    
    eval {
        if (ref $config->{'Model::DBIC'}->{'connect_info'} eq 'HASH') {
            $dsn  = $config->{'Model::DBIC'}->{'connect_info'}->{dsn};
            $user = $config->{'Model::DBIC'}->{'connect_info'}->{user};
            $pass = $config->{'Model::DBIC'}->{'connect_info'}->{password};
        } else {
            ($dsn, $user, $pass) = @{$config->{'Model::DBIC'}->{connect_info}};
        }
    };
    die "Your DSN settings in mojomojo.conf seem invalid: $@\n" if $@;
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
my $page_content = $schema->resultset('Content')->single(
    {
        page    => $page->id,
        version => $page->content_version,
    }
);

$page_content->update({
    precompiled => ''
});
