package MojoMojo::C::Jsrpc;

use strict;
use base 'Catalyst::Base';

MojoMojo->action(

    '.jsrpc/render' => sub {
        my ( $self, $c ) = @_;
        my $output= MojoMojo::M::Core::Page->
                    formatted_content($c->req->base,$c->req->params->{content});
        $c->res->output($output);
    }, '.jsrpc/diff' => sub {
        my ( $self, $c, $revision ) = @_;
        my $page= MojoMojo::M::Core::Revision->retrieve($revision);
        if ($revision->parent) {
        $c->res->output($revision->formatted_diff($c->req->base,
                                                  $revision->parent));
        } else {
        $c->res->output("This is the first revision!");
      }
    }, '.jsrpc/tag' => sub {
        my ( $self, $c, $tag, $node ) = @_;
        $node = MojoMojo::M::Core::Page->get_page($node);
        $node->add_to_tags({tag=>$tag,user=>$c->req->{user}}) if $node;
        $c->req->args([$node]);
        $c->forward('!page/tags');

    }, '.jsrpc/untag' => sub {
        my ( $self, $c, $tag, $node ) = @_;
        $node = MojoMojo::M::Core::Page->get_page($node);
        $tag=MojoMojo::M::Core::Tag->search(page=>$node,
                                            user=>$c->req->{user},
                                            tag=>$tag)->next();
        $tag->delete(); if $tag;
        $c->forward('!page/tags');
    }
    
);

=head1 NAME

MojoMojo::C::Jsrpc - A Component

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
