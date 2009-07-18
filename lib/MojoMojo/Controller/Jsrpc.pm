package MojoMojo::Controller::Jsrpc;

use strict;
use parent 'Catalyst::Controller';
use HTML::Entities;

=head1 NAME

MojoMojo::Controller::Jsrpc - Various JsRPC functions.

=head1 SYNOPSIS

This is the Mojo powering our AJAX features.

=head1 DESCRIPTION

This controller dispatches various data to ajax methods in mojomojo
These methods will be called indirectly through javascript functions.

=head1 ACTIONS

=over 4

=item render (/.jsrpc/render)

Edit uses this to get live preview. It gets some content in
params->{content} and runs it through the formatter chain.

=cut

sub render : Local {
    my ( $self, $c ) = @_;
    my $output = $c->loc("Please type something");
    my $input  = $c->req->params->{content};
    if ( $input && $input =~ /(\S+)/ ) {
        $output = $c->model("DBIC::Content")->format_content( $c, $input );
    }

    unless ($output) {
        $output = $c->loc('Your input is invalid, please reformat it and try again.');
        $c->res->status(500);
    }

    $c->res->output($output);
}

=item child_menu (/.jsrpc/child_menu?page_id=$page_id)

Returns a list of children for the page given by the page_id parameter,
formatted for inclusion in a vertical tree navigation menu.

=cut

sub child_menu : Local {
    my ( $self, $c, $page_id ) = @_;
    $c->stash->{parent_page} = $c->model("DBIC::Page")->find( $c->req->params->{page_id} );
    $c->stash->{template}    = 'child_menu.tt';
}

=item diff (/.jsrpc/diff)

Loads diff on demand. Takes an absolute revision number as arg,
and diffs it against the previous version.

=cut

sub diff : Local {
    my ( $self, $c, $page, $revision, $against, $sparse ) = @_;
    unless ($revision) {
        my $page = $c->model("DBIC::Page")->find($page);
        $revision = $page->content->id;
    }
    $revision = $c->model("DBIC::Content")->search(
        {
            page    => $page,
            version => $revision
        }
    )->next;
    if (
        my $previous = $against
        ? $c->model("DBIC::Content")->search(
            {
                page    => $page,
                version => $against
            }
        )->next
        : $revision->previous
        )
    {
        $c->res->output( $revision->formatted_diff( $c, $previous, $sparse ) );
    }
    else {
        $c->res->output($c->loc("This is the first revision! Nothing to diff against."));
    }
}

=item submittag (/.jsrpc/submittag)

Add a tag through form submit

=cut

sub submittag : Local {
    my ( $self, $c, $page ) = @_;
    $c->forward( '/jsrpc/tag', [ $c->req->params->{tag} ] );
}

=item tag (/.jsrpc/tag)

Add a tag to a page. Returns a list of yours and popular tags.

=cut

sub tag : Local Args(1) {
    my ( $self, $c, $tagname ) = @_;
    ($tagname) = $tagname =~ m/([\w\s]+)/;
    my $page = $c->stash->{page};
    foreach my $tag ( split m/\s/, $tagname ) {
        if (
            $tag
            && !$c->model("DBIC::Tag")->search(
                page   => $page->id,
                person => $c->req->{user_id},
                tag    => $tagname
            )->next()
            )
        {
            $page->add_to_tags(
                {
                    tag    => $tag,
                    person => $c->stash->{user}->id
                }
            ) if $page;
        }
    }
    $c->req->args( [$tagname] );
    $c->forward('/page/inline_tags');
}

=item untag (/.jsrpc/untag)

Remove a tag from a page. Returns a list of yours and popular tags.

=cut

sub untag : Local Args(1) {
    my ( $self, $c, $tagname ) = @_;
    my $page = $c->stash->{page};
    die "Page " . $page . " not found" unless ref $page;
    my $tag = $c->model("DBIC::Tag")->search(
        page   => $page->id,
        person => $c->user->obj->id,
        tag    => $tagname
    )->next();
    $tag->delete() if $tag;
    $c->req->args( [$tagname] );
    $c->forward('/page/inline_tags');
}

=item imginfo (.jsrpc/imginfo)

Inline info on hover for gallery photos.

=cut

sub imginfo : Local {
    my ( $self, $c, $photo ) = @_;
    $c->stash->{photo}    = $c->model("DBIC::Photo")->find($photo);
    $c->stash->{template} = 'gallery/imginfo.tt';
}

=item usersearch (.jsrpc/usersearch)

Backend that handles jQuery autocomplete requests for users.

=cut

sub usersearch : Local {
    my ($self, $c) = @_;
    my $query = $c->req->param('q');

    $c->stash->{template} = "user/user_search.tt";

    if (defined($query) && length($query)) {
        my $rs = $c->model('DBIC::Person')->search_like({
            login => '%'.$query.'%'
        });
        $c->stash->{users} = [ $rs->all ];
    }
}

=item set_permissions (.jsrpc/ser_permissions)

Sets page permissions.

=cut

sub set_permissions : Local {
    my ($self, $c) = @_;

    $c->forward('validate_perm_edit');

    my @path_elements = $c->_expand_path_elements($c->stash->{path});
    my $current_path = pop @path_elements;

    my ( $create, $read, $write, $delete, $attachment, $subpages) =
        map { $c->req->param($_) ? 'yes' : 'no' }
            qw/create read write delete attachment subpages/;

    my $role = $c->stash->{role};

    my $params = {
        path => $current_path,
        role => $role->id,
        apply_to_subpages   => $subpages,
        create_allowed      => $create,
        delete_allowed      => $delete,
        edit_allowed        => $write,
        view_allowed        => $read,
        attachment_allowed  => $attachment
    };

    my $model = $c->model('DBIC::PathPermissions');

    # when subpages should inherit permissions we actually need to update two
    # entries: one for the subpages and one for the current page
    if ($subpages eq 'yes') {
        # update permissions for subpages
        $model->update_or_create( $params );

        # update permissions for the current page
        $params->{apply_to_subpages} = 'no';
        $model->update_or_create( $params );
    }
    # otherwise, we must remove the subpages permissions entry and update the
    # entry for the current page
    else {
        # delete permissions for subpages
        $model->search( {
            path              => $current_path,
            role              => $role->id,
            apply_to_subpages => 'yes'
        } )->delete;

        # update permissions for the current page
        $model->update_or_create($params);
    }

    # clear cache
    if ( $c->pref('cache_permission_data') ) {
        $c->cache->remove( 'page_permission_data' );
    }

    $c->res->body("OK");
    $c->res->status(200);
}

=item clear_permissions (.jsrpc/clear_permissions)

Clears this page permissions for a given role (making permissions inherited).

=cut

sub clear_permissions : Local {
    my ($self, $c) = @_;

    $c->forward('validate_perm_edit');

    my @path_elements = $c->_expand_path_elements($c->stash->{path});
    my $current_path = pop @path_elements;

    my $role = $c->stash->{role};

    if ($role) {

        # delete permissions for subpages
        $c->model('DBIC::PathPermissions')->search( {
            path              => $current_path,
            role              => $role->id
        } )->delete;

        # clear cache
        if ( $c->pref('cache_permission_data') ) {
            $c->cache->remove( 'page_permission_data' );
        }

    }

    $c->res->body("OK");
    $c->res->status(200);

}

=item validate_perm_edit

Validates if the user is able to edit permissions and if a role was supplied.

=cut

sub validate_perm_edit : Private {
    my ($self, $c) = @_;

    my $user = $c->user;

    # only admins can change permissions for now
    unless ($user && $user->is_admin) {
        $c->res->body("Forbidden");
        $c->res->status(403);
        $c->detach;
    }

    my $role = $c->model('DBIC::Role')->find(
        { name => $c->req->param('role_name') }
    );

    unless ($role) {
        $c->res->body('Bad Request');
        $c->res->status(400);
        $c->detach;
    }

    $c->stash->{role} = $role;
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>, David Naughton <naughton@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
