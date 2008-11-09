package MojoMojo::Controller::Attachment;

use strict;
use base 'Catalyst::Controller';

use IO::File;

=head1 NAME

MojoMojo::Controller::Attachment - Attachment controller

=head1 DESCRIPTION

MojoMojo supports attaching files to nodes. This controller handles 
administration and serving of these assets.


=head1 ACTIONS

=head2 auth

Permission control for mojomojo pages.

=cut

sub auth : Private {
    my ( $self, $c ) = @_;
    return $c->forward('/user/login') unless $c->stash->{user};

    my $perms =
        $c->check_permissions( $c->stash->{'path'},
        ( $c->user_exists ? $c->user->obj : undef ) );
    if ( $perms->{'attachment'} ) {
        return 1;
    }

    $c->stash->{template} = 'message.tt';
    $c->stash->{message}  = 'sorry bubba, you aint got no rights';
    return 0;
}

=head2 attachments

main attachment screen.  Handles uploading of new attachments.

=cut

sub attachments : Global {
    my ( $self, $c, $page ) = @_;
    return unless $c->forward('auth');
    $c->stash->{template} = 'page/attachments.tt';
    $page = $c->stash->{page};
    if ( my $file = $c->req->params->{file} ) {
        my $upload = $c->request->upload('file');
        my (@att) =
            $c->model("DBIC::Attachment")
            ->create_from_file( $page, $file, $upload->tempname, $c->path_to('/') );
        if ( !@att ) {
            $c->stash->{template} = 'message.tt';
            $c->stash->{message}  = "Could not create attachment from $file.";
        }
        $c->res->redirect( $c->req->base . $c->stash->{path} . '.attachments' )
            unless $c->stash->{template} eq 'message.tt';
    }

}

sub flash_upload : Local {
    my ( $self, $c ) = @_;
    my $user=$c->model('DBIC::Person')->find($c->req->params->{id});
    $c->detach('/default') unless( $user->hashed($c->pref('entropy')) eq $c->req->params->{verify} );
    $c->forward('attachments');
    if ($c->res->redirect) {
        $c->res->redirect(undef,200);
        return $c->res->body('1');
    }
    $c->res->body('0');
}

sub list : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template}='attachments/list.tt';
}

=head2 default

This action dispatches to the other private actions in this controller
based on the second argument. the first argument is expected to be 
an attachment id.

=cut

sub attachment : Chained CaptureArgs(1) {
    my ( $self, $c, $att ) = @_;
    $c->stash->{att} = $c->model("DBIC::Attachment")->find($att);
    $c->detach('default') unless ( $c->stash->{att} );
}

sub defaultaction : PathPart('') Chained('attachment') Args('') {
    my ( $self, $c ) = @_;
    $c->forward('view');
}

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'message.tt';
    $c->stash->{message}  = "Attachment not found.";
    return ( $c->res->status(404) );
}

sub view : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->res->output( IO::File->new( $c->stash->{att}->filename ) );
    $c->res->headers->header( 'content-type', $c->stash->{att}->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "inline; filename=" . $c->stash->{att}->name );
}

=head2 download

force the attachment to be downloaded, through the use of 
content-disposition.

=cut

sub download : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    my $att = $c->stash->{att};
    $c->forward('view');
    $c->res->headers->header( 'content-type', $att->contenttype );
    $c->res->headers->header( "Content-Disposition" => "attachment; filename=" . $att->name );
}

=head2 thumb

thumb action for attachments. makes 100x100px thumbs

=cut

sub thumb : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    my $att = $c->stash->{att};
    my $photo;
    unless ( $photo = $att->photo ) {
        return $c->res->body('Can only make thumbnails of photos');
    }
    $photo->make_thumb() unless -f $att->thumb_filename;
    $c->res->output( IO::File->new( $att->thumb_filename ) );
    $c->res->headers->header( 'content-type', $att->contenttype );
    $c->res->headers->header( "Content-Disposition" => "inline; filename=" . $att->name );
}

=head2  inline (private);

show inline attachment

=cut

sub inline : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    my $att = $c->stash->{att};
    my $photo;
    unless ( $photo = $att->photo ) {
        return $c->res->body('Can only make inline version of photos');
    }
    $photo->make_inline unless -f $att->inline_filename;
    $c->res->output( IO::File->new( $att->inline_filename ) );
    $c->detach('default') if $@ =~ m/^Could not open/;
    $c->res->headers->header( 'content-type', $c->stash->{att}->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "inline; filename=" . $c->stash->{att}->name );
}

=head2 delete

delete the attachment from this node. Will leave the file on the 
file system.

=cut

sub delete : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    return unless $c->forward('auth');
    $c->stash->{att}->delete();
    $c->forward('/attachment/attachments');
}

=head2 insert

Insert a link to this attachment in the main text of the node.
Will show a thumb for images.
TODO: Write templates for more mime types.

=cut

sub insert : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    return unless $c->forward('auth');
    my $att = $c->stash->{att};
    my ($family) = $att->contenttype =~ m|^([^/]+)|;
    $c->stash->{family} = 'mimetypes/' . $family . '.tt';
    $c->stash->{type}   = 'mimetypes/' . $att->contenttype . '.tt';
    $c->stash->{append} = $c->view('TT')->render( $c, 'page/insert.tt' );
    $c->forward('/pageadmin/edit');
}

=head1 AUTHOR

Marcus Ramberg C<marcus@nordaaker.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.  

=cut

1;
