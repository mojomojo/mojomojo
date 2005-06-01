package MojoMojo::C::Attachment;

use strict;
use base 'Catalyst::Base';
use Archive::Zip qw(:ERROR_CODES);
use File::MimeInfo::Magic;
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

=item attachments

main attachments screen.

=cut

sub attachments : Global {
    my ( $self, $c, $page ) = @_;
    $c->stash->{template} = 'page/attachments.tt';
    $page = $c->stash->{page};
    #got file upload.
    if ( my $file = $c->req->params->{file} ) {
      my $upload=$c->request->upload('file');
      return $c->forward('/user/login') unless $c->req->{user};
      if ($upload->type eq 'application/zip') {
          my $zip=Archive::Zip->new();
          if ( ! $zip->readFromFileHandle( $upload->fh ) == AZ_OK ) {
              $c->stash->{template}='message.tt';
              $c->stash->{message}= "Can't open zipfile for writing.";
              return;
          }
          foreach my $member ($zip->members) {
            next if $member->isDirectory;
              my $att =
                 MojoMojo::M::Core::Attachment->create(
                    { name => $member->fileName, page => $page } );
              my $filename = $c->config->{home} . "/uploads/" . $att->id;
              $member->extractToFileNamed($filename);
              $att->contenttype( mimetype($filename) );
              $att->size( -s $filename );
              $att->update();
          }
       } else {
        my $att =
          MojoMojo::M::Core::Attachment->create
          ( { name => $file, page => $page } );

        my $filename = $c->config->{home} . "/uploads/" . $att->id;
        unless (  $upload->link_to($filename) || 
                  $upload->copy_to($filename) ) {
          $c->stash->{template}='message.tt';
          $c->stash->{message}= "Can't open $filename for writing.";
        }
        $att->contenttype( mimetype($filename) );
        $att->size( -s $filename );
        $att->update();
      }
    }
}

=item index

This action dispatches to the other private actions in this controller
based on the second argument. the first argument is expected to be 
an attachment id.

=cut

sub index : Path('/attachment') {
    my ( $self, $c, $att, $action ) = @_;

    
    $c->stash->{att} = MojoMojo::M::Core::Attachment->retrieve($att);
    if ($action) {
        $c->forward("/attachment/$action");
    }
    unless ( $c->res->output || $c->stash->{template} ) {
        $c->res->output(
            scalar(
                read_file(
                    $c->config->{home}. "/uploads/" . $c->stash->{att}->id
                )
            )
        );
        $c->res->headers->header( 'content-type',
            $c->stash->{att}->contenttype );
        $c->res->headers->header(
            "Content-Disposition" => "inline; filename="
              . $c->stash->{att}->name );
    }
}

=item download

force the attachment to be downloaded, through the use of 
content-disposition.

=cut

sub download : Private {
    my ( $self, $c, $att, $action ) = @_;
    $c->res->output(
        scalar(
            read_file(
                $c->config->{home} . "/uploads/" . 
                $c->stash->{att}->id
            )
        )
    );
    $c->res->headers->header( 'content-type',
        $c->stash->{att}->contenttype );
    $c->res->headers->header(
        "Content-Disposition" => "attachment; filename="
          . $c->stash->{att}->name );
}

sub thumb : Private {
    my ( $self, $c, $att, $action ) = @_;
    $self->make_thumb($c->config->{home} . "/uploads/".
                      $c->stash->{att}->id )
      unless -f $c->config->{home} . "/uploads/" . 
                $c->stash->{att}->id . ".thumb" ;
    $c->res->output(
        scalar(
            read_file(
                $c->config->{home} .   '/uploads/' . 
                $c->stash->{att}->id . '.thumb'
            )
        )
     );
        $c->res->headers->header(
            "Content-Disposition" => "inline; filename="
              . $c->stash->{att}->name );
}


sub make_thumb {
    my ($self,$file)=@_;
    warn "loading $file";
    my $img=Imager->new();
    $img->open(file=>$file,type=>'jpeg') or die $img->errstr;
    my $h=$img->getheight;
    my $w=$img->getwidth;
    my ($image,$result);
    if ($h>$w) {
        $image=$img->scale(xpixels=>80);
            $w=$image->getwidth;
        $result =$image->crop(
                          left=> int(($w-80)/2),
                          top=>0,
                          width=>80,
                            height=>80);
    } else {
        $image=$img->scale(ypixels=>80);
            $h=$image->getheight;
        $result  =$image->crop(
                            top=> int(($h-80)/2),
                            left=>0,
                            width=>80,
                            height=>80);
    }
    $result->write(file=>$file.'.thumb',type=>'jpeg') or die $img->errstr;
}

=item delete

delete the attachment from this node. Will leave the file on the 
file system.

=cut

sub delete : Private {
    my ( $self, $c, $att, $action ) = @_;
    return $c->forward('/user/login') unless $c->req->{user};
    $c->req->args( [ $c->stash->{att}->page->path ] );
    $c->stash->{att}->delete();
    $c->forward('/attachment/attachments');
}

=item insert

Insert a link to this attachment in the main text of the node.
FIXME: should be extended to use a template database based on
mime-type

=cut

sub insert : Private {
    my ( $self, $c, $att, $action ) = @_;
    $c->stash->{att}->page->set_path();
    $c->req->args( [ $c->stash->{att}->page->path ] );
    $c->log->info('path is'.$c->stash->{att}->page->path);
    $c->stash->{append} = "\n\n\""
      . $c->stash->{att}->name . "\":"
      . $c->req->base
      . "/.attachment/"
      . $c->stash->{att};
    $c->forward('/page/edit');
}

=back 

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.  

=cut

1;
