package MojoMojo::Controller::Image;

use strict;
use parent 'Catalyst::Controller';
use IO::File;
use URI::Escape ();

=head1 NAME

MojoMojo::Controller::Image - Image controller

=head1 SYNOPSIS

=head1 DESCRIPTION

This controller is used to see images in particular url

Formatter::Dir must be configured in mojomojo.conf.

If url begin with 'prefix_url', so images can be displayed.

Images are stored in 'whitelisting' directory.

View usage with 'script/util/dir2mojomojo.pl'

=cut

=head2 file_not_found

Private action to return a 404 not found page.

=cut

sub file_not_found : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'message.tt';
    $c->stash->{message}  = $c->loc("file not found.");
    return ( $c->res->status(404) );
}

=head2 png

=cut

sub png : Global {
    my ( $self, $c, $path ) = @_;
    $c->forward('view');

}

=head2 jpg

=cut

sub jpg : Global {
    my ( $self, $c ) = @_;

    $c->forward('view');
}

=head2 gif

=cut

sub gif : Global {
    my ( $self, $c, $path ) = @_;
    $c->forward('view');

}

=head2 tiff

=cut

sub tiff : Global {
    my ( $self, $c, $path ) = @_;
    $c->forward('view');

}

=head2 view

png/jpg/gif are forwarded here. This action  is used to see images

=cut

sub view : Private {
    my ( $self, $c, $path ) = @_;


    $c->detach('unauthorized', ['view']) if not $c->check_view_permission;

    if ( ! defined $c->config->{'Formatter::Dir'}{prefix_url} ||
         ! defined $c->config->{'Formatter::Dir'}{whitelisting} ){

      $c->stash->{message} = "Formatter::Dir is not configured";
      $c->stash->{template} = 'message.tt';
      return ( $c->res->status(404) );
    }

    # Show image only if url start by prefix_url configured 
    # in mojomojo.conf with Formatter::Dir
    my $prefix_url = $c->config->{'Formatter::Dir'}{prefix_url};
    $prefix_url =~ s|\/$||;
    $prefix_url .= '/';


    my $file = $c->stash->{path};
    my $suffix =  $c->req->uri->path;
    $suffix =~ s|^\/||;
    if ( $file !~ s/^$prefix_url// ){
      $c->stash->{message} = $c->loc(
                         'The requested URL was not found: x',
                         "$file.$suffix");

      $c->stash->{template} = 'message.tt';
      return ( $c->res->status(404) );
    }


    my $filename = "$file.$suffix";
    my $dir = $c->config->{'Formatter::Dir'}{whitelisting};

    my $io_file = IO::File->new("$dir/$filename")
        or $c->detach('file_not_found');
    $io_file->binmode;

    $c->res->output( $io_file );
    $c->res->header( 'content-type', $c->action );
    $c->res->header(
        "Content-Disposition" => "inline; filename=" . URI::Escape::uri_escape_utf8( $filename ) );
    $c->res->header( 'Cache-Control', 'max-age=86400, must-revalidate' );
}


=head1 AUTHOR

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
