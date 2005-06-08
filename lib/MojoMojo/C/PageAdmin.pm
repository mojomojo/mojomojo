package MojoMojo::C::PageAdmin;

use strict;
use base 'Catalyst::Base';

my $m_base          = 'MojoMojo::M::Core::';
my $m_page_class    = $m_base . 'Page';
my $m_content_class = $m_base . 'Content';
my $m_verison_class = $m_base . 'PageVersion';

=head1 NAME

MojoMojo::C::PageAdmin - MojoMojo Page Administration

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
    my $user = $c->req->{user};
    my $admins = $c->pref('admins');
    return 1 if $user && $admins =~m/\b$user\b/ ;
    return 1 if $user && $c->stash->{page}->path =~ m|^/$user\b|i; 
    $c->stash->{template}='message.tt';
    $c->stash->{message}='sorry bubba, you aint got no rights';
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
    $c->req->params->{login}=$c->req->params->{creator};

    my $user = $c->req->{user_id} || 0;
    $c->log->info("user is $user");

    my ( $path_pages, $proto_pages ) = @$stash{qw/ path_pages proto_pages /};

    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages) {
        ( $path_pages, $proto_pages ) = $m_page_class->path_pages($path);
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
        $stash->{content} = MojoMojo::M::Core::Content->create_proto($page);
        $stash->{content}->{creator} = $user;
        $c->req->params->{body} = $stash->{content}->{body}
           unless $c->req->params->{body};
        return;
    }

    if ($user == 0 && ! $c->pref('anonymous_user')) {
      $c->stash->{message} ||= 'Anonymous Edit disabled';
      return;
    }
    # else, update the page and redirect to highlight, which will forward to view:
    my $valid   = $c->form->valid;
    my $unknown = $c->form->unknown;

    if (@$proto_pages)    # page doesn't exist yet
    {
        $path_pages = $m_page_class->create_path_pages(
            path_pages  => $path_pages,
            proto_pages => $proto_pages,
            creator     => $user,
        );
        $page = $path_pages->[ @$path_pages - 1 ];
    }
    $page->update_content( %$valid, %$unknown );

    # update the search index with the new content
    my $p = MojoMojo::Search::Plucene->open( $c->config->{home} . "/plucene" );
    $p->update_index( $page );

    $c->res->redirect( $c->req->base . $page->path . '.highlight' );

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
