package MojoMojo::C::Attachment;

use strict;
use base 'Catalyst::Base';
use File::Slurp;

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

=item index

This action dispatches to the other private actions in this controller
based on the second argument. the first argument is expected to be 
an attachment id.

=cut

sub index : Path('/.attachment') {
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

=item delete

delete the attachment from this node. Will leave the file on the 
file system.

=cut

sub delete : Private {
    my ( $self, $c, $att, $action ) = @_;
    return $c->forward('/user/login') unless $c->req->{user};
    $c->req->args( [ $c->stash->{att}->page->path ] );
    $c->stash->{att}->delete();
    $c->forward('/page/attachments');
}

=item insert

Insert a link to this attachment in the main text of the node.
FIXME: should be extended to use a template database based on
mime-type

=cut

sub insert : Private {
    my ( $self, $c, $att, $action ) = @_;
    return $c->forward('/user/login') unless $c->req->{user};
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
