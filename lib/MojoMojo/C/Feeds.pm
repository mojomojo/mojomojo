package MojoMojo::C::Feeds;

use strict;
use base 'Catalyst::Base';

MojoMojo->action(
  '.feeds' => sub {
my ( $self, $c, $node ) = @_;
$c->stash->{template} = 'feeds.tt';
}, '.rss' => sub {
my ( $self, $c, $node ) = @_;
$c->stash->{template} = 'rss.tt';
}, '.rss_full' => sub {
my ( $self, $c, $node ) = @_;
$c->stash->{template} = 'rss_full.tt';
}, '.atom' => sub {
my ( $self, $c, $node ) = @_;
$c->stash->{template} = 'atom.tt';
}

);

=head1 NAME

MojoMojo::C::Feeds - A Component

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
