package MojoMojo::C::Export;
use strict;
use base 'Catalyst::Base';
use Time::Piece;
use Archive::Zip;

my $model = 'MojoMojo::M::Core::Page';

=head1 NAME

MojoMojo::C::Export - Export / Import related controller

=head1 SYNOPSIS


=head1 DESCRIPTION

MojoMojo has an extensive export system. You can download all the 
nodes of the wiki either as preformatted HTML, for offline reading
or in a raw format suitable for reimporting into another MojoMojo
installation. either way, MojoMojo will create and send you a zip 
file with a directory containing all the files. the filename of the
directory will contain a timestamp showing when the archive was made.

=head1 ACTIONS

=over 4

=item raw 

This action will give you a zip file containing the raw wiki source
for all the nodes of the wiki.

=cut

sub raw : Private {
    my ( $self, $c ) = @_;
    #my @pages   = $model->retrieve_all_sorted_by("name");
    my $pages = $c->stash->{pages};
    my $archive = Archive::Zip->new();
    my $prefix  =
        $c->fixw( $c->pref('name') ) . "-"
      . $c->stash->{page}->name 
      . "-export-"
      . localtime->ymd('-') . '-'
      . localtime->hms('-');
    $archive->addDirectory("$prefix/");
    while ( my $page =$pages->next ) {
        next unless $page->content; 
        $archive->addString( $page->content->body, $prefix .  $page->path .($page->path eq '/' ? '' : '/').'index' );
        $c->log->debug('Adding :'.$page->path.($page->path eq '/' ? '' : '/').'index' );
    }
    my $fh = IO::Scalar->new( \$c->res->{body} );
    $archive->writeToFileHandle($fh);
    $c->res->headers->header( "Content-Type" => 'archive/zip' );
    $c->res->headers->header(
        "Content-Disposition" => "attachment; filename=$prefix.zip" );
}

=item html (/.html.zip)

This action will give you a zip file containing HTML formatted 
versions of all the nodes of the wiki.

=cut

sub html : Private {
    my ( $self, $c ) = @_;
    #my @pages   = $model->retrieve_all_sorted_by("name");
    my $pages = $c->stash->{pages};
    my $archive = Archive::Zip->new();
    my $prefix  =
        $c->fixw( $c->pref('name') ) . "."
      . $c->stash->{page}->name 
        . "-html-"
      . localtime->ymd('-') . '-'
      . localtime->hms('-');
    $archive->addDirectory("$prefix/");
    my $home = $c->pref("home_node");
    while ( my $page =$pages->next ) {
        $c->log->debug('Rendering '.$page->path);
        $archive->addString( $c->subreq( $page->path .'.print' ),
            $prefix . $page->path ."/index.html" );
    }
    my $fh = IO::Scalar->new( \$c->res->{body} );
    $archive->writeToFileHandle($fh);
    $c->res->headers->header( "Content-Type" => 'archive/zip' );
    $c->res->headers->header(
        "Content-Disposition" => "attachment; filename=$prefix.zip" );
}

1;
