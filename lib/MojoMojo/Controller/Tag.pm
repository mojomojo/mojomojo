package MojoMojo::Controller::Tag;

use strict;
use parent 'Catalyst::Controller';
use HTML::TagCloud;

=head1 NAME

MojoMojo::Controller::Tag - Tags controller

=head1 SYNOPSIS

Handles the following URLs
  /.tags/
  /.list/<tag>  (dispatched from Page)
  /.recent/<tag>  (dispatched from Page)

=head1 DESCRIPTION

This controller generates a tag cloud and retrieves (all or recent) pages
tagged with a given tag.

=head1 ACTIONS

=head2 list

This is a private action, and is dispatched from
L<E<47>.list|MojoMojo::Controller::Page/list> when supplied with a tag
argument. It will list all pages tagged with the given tag.

=cut

sub list : Private {
    my ( $self, $c, $tag ) = @_;

    return unless $tag;
    $c->stash->{template} = 'page/list.tt';

    $c->stash->{activetag} = $tag;
    $c->stash->{pages}     = [ $c->stash->{page}->tagged_descendants($tag) ];
    $c->stash->{related}   = [ $c->model("DBIC::Tag")->related_to($tag) ];
}

=head2 recent

This is a private action, and is dispatched from
L<E<47>.recent|MojoMojo::Controller::Page/recent> when supplied with a tag
argument. It will list recent pages tagged with the given tag.

=cut

sub recent : Private {
    my ( $self, $c, $tag ) = @_;
    $c->stash->{template} = 'page/recent.tt';
    return unless $tag;
    $c->stash->{activetag} = $tag;
    $c->stash->{pages}     = [ $c->stash->{page}->tagged_descendants_by_date($tag) ];

}

=head2 tags (/.tags)

Tag cloud for pages.

=cut

sub tags : Global {
    my ( $self, $c, $tag ) = @_;
    my $tags = [ $c->model("DBIC::Tag")->by_page( $c->stash->{page}->id ) ];
    my %tags;
    map {
        $tags{$_->tag}++;
    }@$tags;
    my $cloud = HTML::TagCloud->new();
    foreach my $tag (keys %tags) {
        $cloud->add(
            $tag, 
            $c->req->base . $c->stash->{path} . '.list/' . $tag,
            $tags{$tag}
        );
    }
    $c->stash->{cloud}    = $cloud;
    $c->stash->{template} = 'tag/cloud.tt';
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
