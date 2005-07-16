package MojoMojo::C::Attachment;

use strict;
use base 'Catalyst::Base';
use Archive::Zip qw(:ERROR_CODES);
use File::Slurp;
use Imager;

=head1 NAME

MojoMojo::C::Attachment - Attachment controller

=head1 SYNOPSIS

Handles urls like
  /.attachment/14/download
  /.attachment/23/view
  /.attachment/23/insert

=head1 DESCRIPTION

This controller handles node attachments


=head1 ACTIONS

=over 4

=item auth

auth controll for mojomojo

=cut
sub auth : Private {
    my ( $self, $c ) = @_;
    return $c->forward('/user/login') unless $c->stash->{user};
    return 1 if ($c->stash->{user}->can_edit($c->stash->{path}));

    $c->stash->{template}='message.tt';
    $c->stash->{message}='sorry bubba, you aint got no rights';
    return 0;
}

=item attachments

main attachment screen.  Handles uploading of new attachments.

=cut

sub attachments : Global {
    my ( $self, $c, $page ) = @_;
    return unless $c->forward('auth');
    $c->stash->{template} = 'page/attachments.tt';
    $page = $c->stash->{page};
    if ( my $file = $c->req->params->{file} ) {
        my $upload=$c->request->upload('file');
        if ( $upload->type eq 'application/zip' ) {
            my $zip=Archive::Zip->new();
            if ( ! $zip->readFromFileHandle( $upload->fh ) == AZ_OK ) {
                $c->stash->{template} = 'message.tt';
                $c->stash->{message}  = "Can't open zipfile for writing.";
                return;
            }
            foreach my $member ($zip->members) {
                next if $member->isDirectory;
                my $att = MojoMojo::M::Core::Attachment->
                   create_from_file( $page, $member->fileName,
                   {$member->extractToFileNamed(shift)});
                if (! $att ) {
                    $c->stash->{template}='message.tt';
                    $c->stash->{message}= "Can't extract ".
                                        $member->fileName.
                                        " from zip.";
                }
          }
      } else {
          my $att =
          MojoMojo::M::Core::Attachment->create_from_file ( $page, $file, 
              sub { 
                  my $file=shift; 
                  warn "writing $upload to $file"; 
                  $upload->link_to($file) || $upload->copy_to($file);
              } );

          if (! $att ) {
              $c->stash->{template}='message.tt';
              $c->stash->{message}= "Can't open $file for writing.";
          }
       }
    }
}

=item default

This action dispatches to the other private actions in this controller
based on the second argument. the first argument is expected to be 
an attachment id.

=cut

sub default : Private {
    my ( $self, $c, $called, $att, $action ) = @_;

    $att=MojoMojo::M::Core::Attachment->retrieve($att);
    if ($action) {
        $c->forward("$action", [$att,@_] );
    }
    unless ( $c->res->output || $c->stash->{template} || @{$c->error} ) {
        $c->res->output( scalar( read_file( $att->filename)));
        $c->res->headers->header( 'content-type', $att->contenttype );
        $c->res->headers->header(
            "Content-Disposition" => "inline; filename=".$att->name 
        );
    }
}

=item download

force the attachment to be downloaded, through the use of 
content-disposition.

=cut

sub download : Private {
    my ( $self, $c, $att ) = @_;
    $c->res->output( scalar(read_file( $att->filename)) );
    $c->res->headers->header( 'content-type', $att->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "attachment; filename=" . $att->name 
    );
}

=item thumb

thumb action for attachments. makes 100x100px thumbs

=cut

sub thumb : Private {
    my ( $self, $c, $att ) = @_;
    $att->make_thumb() unless -f $att->filename . ".thumb" ;
    $c->res->output( scalar(read_file($att->filename. '.thumb')) );
    $c->res->headers->header( 'content-type', $att->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "inline; filename=" . $att->name 
    );
}

=item  inline (private);

show inline attachment

=cut

sub inline : Private {
    my ( $self, $c, $att ) = @_;
    $att->make_inline
      unless -f $att->filename . ".inline" ;
    $c->res->output(
        scalar( read_file( $att->filename . '.inline'))
     );
    $c->res->headers->header( 'content-type',
        $att->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "inline; filename="
        . $att->name );
}


=item delete

delete the attachment from this node. Will leave the file on the 
file system.

=cut

sub delete : Private {
    my ( $self, $c, $att, $action ) = @_;
    return unless $c->forward('auth');
    $c->stash->{att}->delete();
    $c->forward('/attachment/attachments');
}

=item insert

Insert a link to this attachment in the main text of the node.
Will show a thumb for images.
FIXME: should be extended to use a template database based on
mime-type

=cut

sub insert : Private {
    my ( $self, $c, $att ) = @_;
    return unless $c->forward('auth');
    if ($att->contenttype =~ //) {
        $c->stash->{append} = '\n\n<div class="photo">"!'
            . $c->req->base 
            . "/.attachment/"
            . $att. "/thumb!\":"
            . $c->req->base
            . "/.attachment/"
            . $att.'</div>';
    } else {
        $c->stash->{append} = '\n\n"'
            . $att->name . "\":"
            . $c->req->base
            . "/.attachment/"
            . $att;
    }
        $c->forward('/pageadmin/edit');
}

=back 

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.  

=cut

1;
