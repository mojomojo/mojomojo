package MojoMojo::Controller::PageAdmin;

use strict;
use base 'Catalyst::Controller';

=head1 NAME

MojoMojo::Controller::PageAdmin - MojoMojo Page Administration

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

methods for administration of pages.

=head1 METHODS

=over 4

=item auto

Check that user is logged in and has rights to this page.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->forward('/user/login') if $c->req->params->{pass} && 
                                ! $c->stash->{user};
    # everyone can edit with anon mode enabled.
    return 1 if MojoMojo->pref('anonymous_user');
    my $user = $c->stash->{user};
    return 1 if $user && $user->can_edit($c->stash->{path});
	return 1 if $user && ! $c->pref('restricted_user');
    $c->stash->{template}='message.tt';
    $c->stash->{message}='Sorry bubba, you aint got no rights to this page';
    return 0;
}

=item edit

This action will display the edit form, then save the previous
revision, and create a new based on the posted content.
after saving, it will forward to the highlight action.

=cut

sub edit : Global {
    my ( $self, $c, $path ) = @_;

    # Set up the basics. Log in if there's a user.
    my $stash = $c->stash;
    $stash->{template} = 'page/edit.tt';

    my $user = $c->user_exists ? $c->user->obj->id : 1; # Anon edit

    my ( $path_pages, $proto_pages ) = @$stash{qw/ path_pages proto_pages /};

    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages) {
        ( $path_pages, $proto_pages ) = $c->model('DBIC::Page')->path_pages($path);
    }

    # the page we're editing is at the end of either path_pages or 
    # proto_pages, # depending on whether or not the page already exists
    my $page =
      (   @$proto_pages > 0
        ? $proto_pages->[ @$proto_pages - 1 ]
        : $path_pages->[ @$path_pages - 1 ] );

    # this should never happen!
    die "Cannot determine what page to edit for path: $path" unless $page;
    @$stash{qw/ path_pages proto_pages /} = ( $path_pages, $proto_pages );

    $c->form(
        # may need to add more required fields...
        required => [qw/body/],
        defaults => { creator => $user, }
    );

    # if we have missing or invalid fields, display the edit form.
    # this will always happen on the initial request
    if ( $c->form->has_missing || $c->form->has_invalid ) {
        $stash->{page}    = $page;
        # Note that this isn't a real Content object, just a proto object!!!
        # It's just a hash, not blessed into the Content package.
        $stash->{content} = $c->model("DBIC::Content")->create_proto($page);
        $stash->{content}->{creator} = $user;
        $c->req->params->{body} = $stash->{content}->{body}
           unless $c->req->params->{body};
        return;
    }

    if ($user == 1 && ! $c->pref('anonymous_user')) {
      $c->stash->{message} ||= 'Anonymous Edit disabled';
      return;
    }
    # else, update the page and redirect to highlight, which will forward to view:
    my $valid   = $c->form->valid;
    $valid->{creator} = $user;
    my $unknown = $c->form->unknown;

    if (@$proto_pages)    # page doesn't exist yet
    {
        $path_pages = $c->model('DBIC::Page')->create_path_pages(
            path_pages  => $path_pages,
            proto_pages => $proto_pages,
            creator     => $user,
        );
        $page = $path_pages->[ @$path_pages - 1 ];
    }
    $c->model("DBIC::Page")->set_paths(@$path_pages);
    $page->update_content( %$valid, %$unknown );


    # update the search index with the new content
    # FIXME: Disabling search engine for now.
    $c->model('Search::Plucene')->index_page( $page );
    $c->model("DBIC::Page")->set_paths($page);
    $page->content->store_links();

    $c->res->redirect( $c->req->base . $c->stash->{path} . '.highlight' );

} # end sub edit


=item rollback

=cut

sub rollback : Global {
    my ( $self, $c, $page ) = @_;
    if ($c->req->param('rev')) {
      $c->stash->{page}->content_version($c->req->param('rev'));
      $c->stash->{page}->update;
      undef $c->req->params->{rev};
      $c->forward('/page/view');
    }
}

=back


=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
