package MojoMojo::C::Attachment;

use strict;
use base 'Catalyst::Base';
use File::Slurp;

MojoMojo->action(

    '.attachment' => sub {
        my ( $self, $c, $att, $action ) = @_;
        $c->stash->{att}=MojoMojo::M::Core::Attachment->retrieve($att);
        if ($action) {
            $c->forward("!attachment/$action");
        } 
        unless ($c->res->output || $c->stash->{template}) {
            $c->res->output(scalar(read_file($c->home().
                            "/uploads/".$c->stash->{att}->id)));
            $c->res->headers->header('content-type',
                                     $c->stash->{att}->contenttype);
            $c->res->headers->header("Content-Disposition" =>
                      "inline; filename=".
                      $c->stash->{att}->name);
        }
    }, '!attachment/download'=> sub {
            my ( $self, $c, $att, $action ) = @_;
            $c->res->output(scalar(read_file($c->home().
                            "/uploads/".$c->stash->{att}->id)));
            $c->res->headers->header('content-type',
                                     $c->stash->{att}->contenttype);
            $c->res->headers->header("Content-Disposition" =>
                      "attachment; filename=".
                      $c->stash->{att}->name);
    }, '!attachment/delete' => sub {
        my ( $self, $c, $att, $action ) = @_;
        $c->req->args([$c->stash->{att}->page->node]);
        $c->stash->{att}->delete();
        $c->forward('!page/upload');
    }, '!attachment/insert' => sub {
        my ( $self, $c, $att, $action ) = @_;
        $c->req->args([$c->stash->{att}->page->node]);
        $c->stash->{append}="\n\n\"".$c->stash->{att}->name."\":".
                            $c->req->base.".attachment/".
                            $c->stash->{att};
        $c->forward('!page/edit');
    }
);

=head1 NAME

MojoMojo::C::Attachment - A Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
