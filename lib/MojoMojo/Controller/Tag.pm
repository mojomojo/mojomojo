package MojoMojo::Controller::Tag;

use strict;
use parent 'Catalyst::Controller';
use HTML::TagCloud;

=head1 NAME

MojoMojo::Controller::Tag - Tags controller

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

    return unless $tag;
    $c->stash->{template} = 'page/list.tt';

    $c->stash->{activetag} = $tag;
    $c->stash->{pages}     = [ $c->stash->{page}->tagged_descendants($tag) ];
    $c->stash->{related}   = [ $c->model("DBIC::Tag")->related_to($tag) ];
}

=item recent

This is a private action, and is dispatched from /.recent when it's
supplied with a tag argument. it will list recent pages belonging
to a certain tag.

=cut

sub recent : Private {
    my ( $self, $c, $tag ) = @_;
    $c->stash->{template} = 'page/recent.tt';
    return unless $tag;
    $c->stash->{activetag} = $tag;
    $c->stash->{pages}     = [ $c->stash->{page}->tagged_descendants_by_date($tag) ];

}

=item tags (/.tags)

tag cloud for pages.

=cut

sub tags : Global {
    my ( $self, $c, $tag ) = @_;
    $c->stash->{tags} = [ $c->model("DBIC::Tag")->by_page( $c->stash->{page}->id ) ];
    my $cloud = HTML::TagCloud->new();
    foreach my $tag ( @{ $c->stash->{tags} } ) {
        $cloud->add( $tag->tag, $c->req->base . $c->stash->{path} . '.list/' . $tag->tag,
            $tag->refcount );
    }
    $c->stash->{cloud}    = $cloud;
    $c->stash->{template} = 'tag/cloud.tt';
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
