package MojoMojo::C::Feeds;

use strict;
use base 'Catalyst::Base';

MojoMojo->action(
'.feeds' => sub {
    my ( $self, $c, $node ) = @_;
    $c->stash->{template} = 'feeds.tt';
}, '.rss' => sub {
    my ( $self, $c, $node ) = @_;
    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
    $c->stash->{template} = 'rss.tt';
}, '.rss_full' => sub {
    my ( $self, $c, $node ) = @_;
    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
    $c->stash->{template} = 'rss_full.tt';
}, '.atom' => sub {
    my ( $self, $c, $node ) = @_;
    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
    $c->stash->{template} = 'atom.tt';
}, '!page/rss' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/rss.tt';
      $c->forward('!page/view');
  }, '!page/atom' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/atom.tt';
      $c->forward('!page/view');
  }, '!page/rss_full' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/rss_full.tt';
      $c->forward('!page/view');
  }, '!page/highlight' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/highlight.tt';
      $c->forward('!page/view');
});

=head1 NAME

MojoMojo::C::Feeds - Controller for RSS feeds.

=head1 SYNOPSIS

    .feeds, .rss, .rss_full, .atom, 
    MyPage.rss, MyPage.atom 

=head1 DESCRIPTION

This controller provides RSS and Atom syndication of the MojoMojo
Wiki

=head1 AUTHOR

Marcus Ramberg <marcus@thefeed.no>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
