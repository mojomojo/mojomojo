package MojoMojo::C::Feeds;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Feeds - Controller for RSS feeds.

=head1 SYNOPSIS

    .feeds, .rss, .rss_full, .atom, 
    MyPage.rss, MyPage.atom 

=head1 DESCRIPTION

This controller provides RSS and Atom syndication of the MojoMojo
Wiki

=head1 ACTIONS

=over4

=item index (/.feeds)

An overview page for the various available feeds.

=cut

sub index : Path('/.feeds') {
    my ( $self, $c, $node ) = @_;
    $c->stash->{template} = 'feeds.tt';
}

=item rss (/.rss)

An RSS 1.1 feed showing the headlines of latest 
changed/added nodes.

=cut

sub rss : Path('/.rss') {
    my ( $self, $c, $node ) = @_;
    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
    $c->stash->{template} = 'rss.tt';
} 

=item rss_full (/.rss_full)

An RSS 1.1 feed showing the full text of the  latest 
changed/added nodes.

=cut

sub rss_full : Path('/.rss_full') {
    my ( $self, $c, $node ) = @_;
    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
    $c->stash->{template} = 'rss_full.tt';
} 

=item atom (/.rss_full)

An Atom feed showing the full text of the  latest 
changed/added nodes.

=cut

sub atom : Path('/.atom') {
    my ( $self, $c, $node ) = @_;
    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
    $c->stash->{template} = 'atom.tt';
}

=head1 AUTHOR

Marcus Ramberg <marcus@thefeed.no>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
