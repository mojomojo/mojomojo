package MojoMojo::Controller::Attachment;

use strict;
use parent 'Catalyst::Controller';

use IO::File;
use URI::Escape ();

=head1 NAME

MojoMojo::Controller::Attachment - Attachment controller

=head1 DESCRIPTION

MojoMojo supports attaching files to nodes. This controller handles
administration and serving of these assets.


=head1 ACTIONS

=head2 auth

Return whether the current user has attachment manipulation rights (upload/delete).

=cut

sub auth : Private {
    my ( $self, $c ) = @_;

    my $perms =
        $c->check_permissions( $c->stash->{'path'},
        ( $c->user_exists ? $c->user->obj : undef ) );
    return $perms->{'attachment'}
}

=head2 unauthorized

Private action to return a 403 with an explanatory template.

=cut

sub unauthorized : Private {
    my ( $self, $c, $operation ) = @_;
    $c->stash->{template} = 'message.tt';
    $c->stash->{message}  = $c->loc('You do not have permissions to x attachments for this page', $operation);
    $c->response->status(403);  # 403 Forbidden
}

=head2 default

Private action to return a 404 not found page.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'message.tt';
    $c->stash->{message}  = $c->loc("Attachment not found.");
    return ( $c->res->status(404) );
}

=head2 attachments

Main attachment screen.  Handles uploading of new attachments.

=cut

sub attachments : Global {
    my ( $self, $c ) = @_;

    $c->detach('unauthorized', ['view']) if not $c->check_view_permission;

    $c->stash->{template} = 'page/attachments.tt';
}

=head2 list

Display the list of attachments if the user has view permissions.

B<template>: F<attachments/list.tt>

=cut

sub list : Local {
    my ( $self, $c ) = @_;

    $c->detach('unauthorized', ['view']) if not $c->check_view_permission;

    $c->stash->{template}='attachments/list.tt';
}

=head2 plain_upload

Upload feature that uses the traditional upload technique.

=cut

sub plain_upload : Global {
    my ( $self, $c ) = @_;
    $c->detach('unauthorized', ['upload']) if not $c->forward('auth');
    $c->forward('check_file');
}

=head2 check_file

Check if the file(s) uploaded could be added to the Attachment table.

=cut
sub check_file : Private  {
    my ($self,$c)=@_;
    my $page = $c->stash->{page};
    if ( my $file = $c->req->params->{file} ) {
        my $upload = $c->request->upload('file');
        my (@att) =  # an array is returned if a ZIP upload was unpacked
            $c->model("DBIC::Attachment")
            ->create_from_file( $page, $file, $upload->tempname );
        if ( !@att ) {
            $c->stash->{template} = 'message.tt';
            $c->stash->{message}  = $c->loc("Could not create attachment from x", $file);
        }

        my $redirect_uri = $c->uri_for('attachments', {plain => $c->req->params->{plain}});
        $c->res->redirect($redirect_uri)  # TODO weird condition. This should be an else to the 'if' above
            unless defined $c->stash->{template} && $c->stash->{template} eq 'message.tt';
    }
}

=head2 flash_upload

Upload feature that uses flash

=cut

sub flash_upload : Local {
    my ( $self, $c ) = @_;

    my $user = $c->model('DBIC::Person')->find( $c->req->params->{id} );

    $c->detach('/default')
        unless (
        $user->hashed( $c->pref('entropy') ) eq $c->req->params->{verify} );

    $c->forward('check_file');

    if ( $c->res->redirect ) {
        $c->res->redirect( undef, 200 );
        return $c->res->body('1');
    }

    $c->res->body('0');
}

=head2 attachment

Find and stash an attachment.

=cut

sub attachment : Chained CaptureArgs(1) {
    my ( $self, $c, $att ) = @_;

    # DBIC complains if find argument is not numeric
    if ( $att !~ /^\d+$/ ) {
      $c->detach('default');
    }
    $c->stash->{att} = $c->model("DBIC::Attachment")->find($att)
        or $c->detach('default');
}

=head2 defaultaction

Set the default action for an attachment which is forwarding to a view.

=cut

sub defaultaction : PathPart('') Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('view');
}

=head2 view

Render the attachment in the browser (C<Content-Disposition: inline>), with
caching for 1 day.

=cut

sub view : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    my $att = $c->stash->{att};
    $c->detach('unauthorized', ['view']) if not $c->check_view_permission;

    # avoid broken binary files
    my $io_file = IO::File->new( $att->filename )
        or $c->detach('default');
    $io_file->binmode;

    $c->res->output( $io_file );
    $c->res->header( 'content-type', $att->contenttype );
    $c->res->header(
        "Content-Disposition" => "inline; filename=" . URI::Escape::uri_escape_utf8( $att->name ) );
    $c->res->header( 'Cache-Control', 'max-age=86400, must-revalidate' );
}

=head2 download

Forwards to L</view> then forces the attachment to be downloaded
(C<Content-Disposition: attachment>) and disables caching.

=cut

sub download : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('view');
    $c->res->header( "Content-Disposition" => "attachment; filename=" . URI::Escape::uri_escape_utf8( $c->stash->{att}->name ) );
    $c->res->header( 'Cache-Control', 'no-cache' );

}

=head2 thumb

Thumb action for attachments. Makes 100x100px thumbnails.

=cut

sub thumb : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->detach('unauthorized', ['view']) if not $c->check_view_permission;
    my $att = $c->stash->{att};
    my $photo;
    unless ( $photo = $att->photo ) {
        return $c->res->body($c->loc('Can only make thumbnails of photos'));
    }
    $photo->make_thumb() unless -f $att->thumb_filename;
    my $io_file = IO::File->new( $att->thumb_filename )
        or $c->detach('default');
    $io_file->binmode;

    $c->res->output( $io_file );
    $c->res->header( 'content-type', $att->contenttype );
    $c->res->header( "Content-Disposition" => "inline; filename=" . URI::Escape::uri_escape_utf8( $att->name ) );
    $c->res->header( 'Cache-Control', 'max-age=86400, must-revalidate' );

}

=head2 inline

Show 800x600 inline versions of photo attachments.

=cut

sub inline : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->detach('unauthorized', ['view']) if not $c->check_view_permission;
    my $att = $c->stash->{att};
    my $photo;
    unless ( $photo = $att->photo ) {
        return $c->res->body($c->loc('Can only make inline version of photos'));
    }
    $photo->make_inline unless -f $att->inline_filename;
    my $io_file = IO::File->new( $att->inline_filename )
        or $c->detach('default');
    $io_file->binmode;

    $c->res->output( $io_file );
    $c->res->header( 'content-type', $c->stash->{att}->contenttype );
    $c->res->header(
        "Content-Disposition" => "inline; filename=" . URI::Escape::uri_escape_utf8( $c->stash->{att}->name ) );
    $c->res->header( 'Cache-Control', 'max-age=86400, must-revalidate' );

}

=head2 delete

Delete the attachment from this node. Will leave the original file on the
file system but delete its thumbnail and inline versions.

=cut

sub delete : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->detach('unauthorized', ['delete']) if not $c->forward('auth');
    $c->stash->{att}->delete();
    $c->forward('attachments');
}

=head1 AUTHOR

Marcus Ramberg C<marcus@nordaaker.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
