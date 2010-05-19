package MojoMojo::Controller::Export;

use strict;
use parent 'Catalyst::Controller';

use Archive::Zip;
use DateTime;
use Encode ();

my $model = '$c->model("DBIC::Page")';

=head1 NAME

MojoMojo::Controller::Export - Export / Import related controller

=head1 SYNOPSIS


=head1 DESCRIPTION

MojoMojo has an extensive export system. You can download all the
nodes of the wiki either as preformatted HTML, for offline reading
or in a raw format suitable for reimporting into another MojoMojo
installation. Either way, MojoMojo will create and send you a zip
file with a directory containing all the files. The name of the
directory will contain a timestamp showing when the archive was made.

=head1 ACTIONS

=head2 generate_export_filename

Create the filename under which we export pages.

=cut

sub generate_export_filename {
    my ($c, $export_type) = @_;
    my $now = DateTime->now();
    
    my $prefix = sprintf("%s-%s-$export_type-%s",
        $c->fixw( $c->pref('name') ),
        substr($c->stash->{page}->path, 1),  # skip the leading slash, because it will be replaced by an underscore
        $now->ymd . 'T' . $now->hms('-')
    );
    $prefix =~ s|/|_|g;
    return $prefix;
}

=head2 export_raw

This action will give you a ZIP file containing the raw wiki source
for all the nodes of the wiki.

=cut

sub export_raw : Global {
    my ( $self, $c ) = @_;
    my $prefix = generate_export_filename($c, 'markup');

    unless ( $c->res->{body} = $c->cache->get($prefix) ) {
        my @pages   = $c->stash->{page}->descendants;
        my $archive = Archive::Zip->new();
        $archive->addDirectory("$prefix/");
        foreach my $page (@pages) {
            next if not $page->content;
            # XXX - see notes from export_html about encode_utf8
            $archive->addString(
                Encode::encode_utf8($page->content->body),
                $prefix . $page->path . ( $page->path eq '/' ? '' : '/' ) . 'index' );
        }
        my $fh = IO::Scalar->new( \$c->res->{body} );
        $archive->writeToFileHandle($fh);
        $c->cache->set( $prefix, $c->res->body );
    }
    $c->res->headers->header( "Content-Type"        => 'archive/zip' );
    $c->res->headers->header( "Content-Disposition" => "attachment; filename=$prefix.zip" );
}

=head2 export_html (/.export_html)

This action will give you a ZIP file containing HTML formatted
versions of all the nodes of the wiki.

=cut

sub export_html : Global {
    my ( $self, $c ) = @_;
    my $prefix = generate_export_filename($c, 'html');

    unless ( $c->res->{body} = $c->cache->get($prefix) ) {
        my @pages   = $c->stash->{page}->descendants;
        my $archive = Archive::Zip->new();
        $archive->addDirectory("$prefix/");
        foreach my $page (@pages) {
            $c->log->debug( 'Rendering ' . $page->path );
            # XXX - Note: subreq calls and gets unicode data from Catalyst
            # (because we're using Plugin::Unicode ;). However,
            # seems like Compress::Zlib expects octets -- so we explicitly
            # encode them back to utf8 - lestrrat
            $archive->addString(
                Encode::encode_utf8($c->subreq( '/print', { path => $page->path } )),
                $prefix . $page->path . "/index.html"
            );
        }
        my $fh = IO::Scalar->new( \$c->res->{body} );
        $archive->writeToFileHandle($fh);
        $c->cache->set( $prefix, $c->res->body );
    }
    $c->res->headers->header( "Content-Type"        => 'archive/zip' );
    $c->res->headers->header( "Content-Disposition" => "attachment; filename=$prefix.zip" );
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
