package MojoMojo::C::Tag;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Attachment - Attachment controller

=head1 SYNOPSIS

Handles urls like
  /.recent/macro
  /.list/flooobs
  /.recent/flood

=head1 DESCRIPTION

This controller handles tag-related actions

=head1 ACTIONS

=over 4

=item list

This is a private action, and is dispatched from /.list when it's
supplied with a tag argument. it will list all pages belonging
to a certain tag.

=cut

sub list : Private {
    my ( $self, $c, $tag ) = @_;

    $c->stash->{template} = 'tag/list.tt';
    return unless $tag;

    $c->stash->{activetag} = $tag;
    $c->stash->{tags}      = [ MojoMojo::M::Core::Tag->search_most_used ];
    $c->stash->{pages}     = [ MojoMojo::M::Core::Page->search_by_tag($tag) ];
    $c->stash->{related}   = [ MojoMojo::M::Core::Tag->related_to($tag) ];
}

=item recent

This is a private action, and is dispatched from /.recent when it's
supplied with a tag argument. it will list recent pages belonging
to a certain tag.

=cut

sub recent : Private {
    my ( $self, $c, $tag ) = @_;
    $c->stash->{template} = 'tag/recent.tt';
    return unless $tag;
    $c->stash->{activetag} = $tag;
    $c->stash->{tags}      = [ MojoMojo::M::Core::Tag->search_most_used ];
    $c->stash->{pages}     =
      [ MojoMojo::M::Core::Page->search_by_tag_and_date($tag) ];
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
