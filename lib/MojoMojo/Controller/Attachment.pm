package MojoMojo::Controller::Attachment;

use strict;
use base 'Catalyst::Controller';
use Archive::Zip qw(:ERROR_CODES);

use MojoMojo;
use File::MMagic;
my $mm=File::MMagic->new(MojoMojo->path_to('magic'));

use File::Slurp;
use Imager;

=head1 NAME

MojoMojo::Controller::Attachment - Attachment controller

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
        if ( $mm->checktype_filename($upload->tempname) eq 'application/zip' ) {
            my $zip;
            $zip=Archive::Zip->new($upload->tempname);
            if ( ! $zip ) {
                $c->stash->{template} = 'message.tt';
                $c->stash->{message}  = "Can't open zipfile for reading.";
                return;
            }
            foreach my $member ($zip->members) {
                next if $member->isDirectory;
                my $att = $c->model("DBIC::Attachment")->
                   create_from_file( $page, $member->fileName,
                   sub {my $file=shift;
                    $member->extractToFileNamed($file)});
                if (! $att ) {
                    $c->stash->{template}='message.tt';
                    $c->stash->{message}= "Can't extract ".
                                        $member->fileName.
                                        " from zip.";
                }
          }
      } else {
          my $att =
          $c->model("DBIC::Attachment")->create_from_file ( $page, $file, 
              sub { 
                  my $file=shift; 
                  warn "saving to $file";
                  $upload->link_to($file) || $upload->copy_to($file);
              } );

          if (! $att ) {
              $c->stash->{template}='message.tt';
              $c->stash->{message}= "Can't open $file for writing.";
          }
       }
    $c->res->redirect( $c->req->base . $c->stash->{path} . '.attachments' )
	    unless $c->stash->{template} eq 'message.tt';
    }
}

sub progress : Global {
    my ( $self, $c, $upload_id ) = @_;
    $c->stash->{progress} = $c->upload_progress( $upload_id );
    $c->stash->{template} = 'attachments/progress.tt';
}


=item default

This action dispatches to the other private actions in this controller
based on the second argument. the first argument is expected to be 
an attachment id.

=cut

sub attachment : Chained CaptureArgs(1) {
    my ( $self, $c, $att ) = @_;
    $c->stash->{att}=$c->model("DBIC::Attachment")->find($att);
    $c->detach('default') unless ($att);
}


sub defaultaction : PathPart('') Chained('attachment') Args('') {
    my ( $self, $c ) = @_;
    $c->forward('view');
}

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template}='message.tt';
    $c->stash->{message}= "Attachment not found.";
    return ( $c->res->status(404) );
}

sub view : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->res->output( scalar( read_file( 
      $c->path_to('uploads',$c->stash->{att}->id).""))); 
    $c->res->headers->header( 'content-type', $c->stash->{att}->contenttype );
    $c->res->headers->header("Content-Disposition" => "inline; filename=".
		$c->stash->{att}->name);
}

=item download

force the attachment to be downloaded, through the use of 
content-disposition.

=cut

sub download : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
	my $att=$c->stash->{att};
	$c->forward('view');
    $c->res->headers->header( 'content-type', $att->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "attachment; filename=" . $att->name 
    );
}

=item thumb

thumb action for attachments. makes 100x100px thumbs

=cut

sub thumb : Chained('attachment') Args(0) {
    my ( $self, $c) = @_;
	my $att=$c->stash->{att};
    $att->make_thumb() unless -f 
       $c->path_to('uploads',$att->id . ".thumb");

    $c->res->output( scalar(read_file(
        $c->path_to('uploads',$att->id).'.thumb')));
    $c->res->headers->header( 'content-type', $att->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "inline; filename=" . $att->name );
}

=item  inline (private);

show inline attachment

=cut

sub inline : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{att}->make_inline
      unless -f $c->path_to('uploads',$c->stash->{att}->id . '.inline');
    $c->res->output(
        scalar( read_file( 
           $c->path_to('uploads',$c->stash->{att}->id) . '.inline')
     ));
    $c->detach('default') if $@ =~ m/^Could not open/;
    $c->res->headers->header( 'content-type',
        $c->stash->{att}->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "inline; filename=". $c->stash->{att}->name );
}


=item delete

delete the attachment from this node. Will leave the file on the 
file system.

=cut

sub delete: Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
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

sub insert : Chained('attachment') Args(0) {
    my ( $self, $c ) = @_;
    return unless $c->forward('auth');
    my $att=$c->stash->{att};
	if ($att->contenttype =~ /^image/) {
        $c->stash->{append} = '\n\n<div class="photo">"!'
            . $c->uri_for("attachment",$att->id,'thumb')."!\":"
            . $c->uri_for("attachment",$att->id).'</div>';
    } else {
        $c->stash->{append} = '\n\n"'
            . $att->name . "\":"
            . $c->uri_for("attachment",$att->id);
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
