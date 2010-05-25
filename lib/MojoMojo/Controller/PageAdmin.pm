package MojoMojo::Controller::PageAdmin;
use warnings;
use strict;
use parent 'Catalyst::Controller::HTML::FormFu';

eval {require Syntax::Highlight::Engine::Kate};
my $kate_installed = !$@;

=head1 NAME

MojoMojo::Controller::PageAdmin - MojoMojo Page Administration

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

Methods for updating pages: edit, rollback, permissions change, rename.

=head1 METHODS

=head2 auto

Check that user is logged in and has rights to this page.

=cut

=head2 unauthorized

Private action to return a 403 with an explanatory template.

=cut

sub unauthorized : Private {
    my ( $self, $c, $operation ) = @_;
    $c->stash->{template} = 'message.tt';
    $c->stash->{message} ||= $c->loc('No permissions to x this page', $operation || $c->loc('update'));
    $c->response->status(403) unless $c->response->status;  # 403 Forbidden
    return 0;
}

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->forward('/user/login')
        if $c->req->params->{pass}  # XXX use case?
          && !$c->stash->{user};

    # everyone can edit with anon mode enabled.
    return 1 if MojoMojo->pref('anonymous_user');
    my $user = $c->stash->{user};
    return 1 if $user && $user->can_edit( $c->stash->{path} );
    return 1 if $user && !$c->pref('restricted_user');
    $c->detach('unauthorized', [$c->loc('edit')]);
}

=head2 edit

This action will display the edit form, then save the previous
revision, and create a new one based on the posted content.
After saving, it will forward to the highlight action.

=cut

sub edit : Global FormConfig {
    my ( $self, $c, $path ) = @_;

    # Set up the basics. Log in if there's a user.
    my $form  = $c->stash->{form};
    my $stash = $c->stash;
    $stash->{template} = 'page/edit.tt';

    my $user_id = $c->user_exists ? $c->user->obj->id : 1;  # Anon edit

    my ( $path_pages, $proto_pages ) = @$stash{qw/ path_pages proto_pages /};

    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages) {
        ( $path_pages, $proto_pages ) =
          $c->model('DBIC::Page')->path_pages($path);
    }

    # the page we're editing is at the end of either path_pages or
    # proto_pages, depending on whether or not the page already exists
    my $page = (
          @$proto_pages > 0
        ? $proto_pages->[-1]
        : $path_pages->[-1]
    );
    @$stash{qw/ path_pages proto_pages /} = ( $path_pages, $proto_pages );

    my $perms =
      $c->check_permissions( $stash->{'path'},  $c->user_exists ? $c->user->obj : undef );
    my $permtocheck = ( @$proto_pages > 0 ? 'create' : 'edit' );
    my $loc_permtocheck = $permtocheck eq 'create'
      ? $c->loc('create')
      : $c->loc('edit');

    # TODO this should be caught in the auto action. To reproduce, disable "Edit allowed by default"
    # in Site settings, then go to /.edit
    if ( !$perms->{$permtocheck} ) {
        my $name = ref($page) eq 'HASH' ? $page->{name} : $page->name;
        $stash->{message} =
          $c->loc( 'Permission denied to x x', [ $loc_permtocheck, $name ] );
        $c->detach('unauthorized');
    }
    # TODO in the use case above, the message below should be displayed. However, that never happens
    if ( $user_id == 1 && !$c->pref('anonymous_user') ) {
        $c->stash->{message} = $c->loc('Anonymous edit disabled');
        $c->detach('unauthorized');
    }

    # for anonymous users, use CAPTCHA, if enabled
    if ( $user_id == 1 && $c->pref('use_captcha') ) {
        my $captcha_lang = $c->session->{lang} || $c->pref('default_lang') ;
        $c->stash->{captcha} = $form->element({
            type => 'reCAPTCHA',
            name => 'captcha',
            recaptcha_options => {
                lang  => $captcha_lang,
                theme => 'white'
            }
        });
        $form->process;
    }

    # prepare the list of available syntax highlighters
    if ($kate_installed) {
        my $syntax = new Syntax::Highlight::Engine::Kate;
        # 'Alerts' is a hidden Kate module, so delete it from list
        $c->stash->{syntax_formatters} = [ grep ( !/^Alerts$/ , $syntax->languageList() ) ];
    }    

    if ( $form->submitted_and_valid ) {

        my $valid = $form->params;
        $valid->{creator} = $user_id;

        if (@$proto_pages) {    # page doesn't exist yet

            $path_pages = $c->model('DBIC::Page')->create_path_pages(
                path_pages  => $path_pages,
                proto_pages => $proto_pages,
                creator     => $user_id,
            );
            $page = $path_pages->[-1];
            

            # update the pages that wanted the new one

        }

        $stash->{content} = $page->content;
        $c->model("DBIC::Page")->set_paths(@$path_pages);

        # refetch page to have ->content available, else it will break in DBIC 0.08099_05 and later
        #$page = $c->model("DBIC::Page")->find( $page->id );
        $page->discard_changes;

        if( $c->stash->{content} &&
            $c->req->params->{version} != $c->stash->{content}->version ) {
            $c->stash->{message}=$c->loc('Someone else changed the page while you edited. Your changes has been merged. Please review and save again');
            my $orig_content = $c->model("DBIC::Content")->find(
                {
                    page    => $page->id,
                    version => $c->req->params->{version},
                }
            );
            $c->stash->{merged_body} ||= $orig_content->merge_content(
                $c->stash->{content},
                $form->params->{body},
                $c->loc('THEIR CHANGES'),
                $c->loc('YOUR CHANGES'),
                $c->loc('END OF CONFLICT'));
            return;
        }
        # Format content body and store the result in content.precompiled 
        # This speeds up MojoMojo page rendering on /.view actions
        my $precompiled_body = $valid->{'body'};
        MojoMojo->call_plugins( 'format_content', \$precompiled_body, $c, $page );

        # Make precompiled empty when we have any of: redirect, comment or include
        $valid->{'precompiled'} = $c->stash->{precompile_off} ? '' : $precompiled_body;

        $page->update_content(%$valid);

        # update the search index with the new content
        $c->model("DBIC::Page")->set_paths($page);
        $c->model('Search')->index_page($page)
            unless $c->pref('disable_search');
        $page->content->store_links();

        # Redirect back to edits or view page mode.
        my $redirect = $c->uri_for( $c->stash->{path} );
        if ( $form->params->{submit} eq $c->localize('Save') ) {
            $redirect .= '.edit';
        }
        $c->res->redirect($redirect);
    }
    else {

        # if we have missing or invalid fields, display the edit form.
        # this will always happen on the initial request
        $stash->{page} = $page;

        # Insert an attachment, or inline an image.
        my %attachment_template = (
            insert_attachment       => 'page/insert.tt',
            inline_image_attachment => 'page/inline_image.tt',
        );
        foreach my $attachment_action ( keys %attachment_template ) {
            if (my $attachment_id = $c->req->query_params->{$attachment_action} ) {
                my $saved_stash = $stash;

                my $attachment = $c->model("DBIC::Attachment")
                                   ->find( { id => $attachment_id } );

                $c->stash( { att => $attachment } );

                my $insert_text = $c->view('TT')->render( $c, $attachment_template{$attachment_action} );
                $insert_text =~ s/^\s+|\s+$//;

                $c->stash($saved_stash);

                $page->content->body( $page->content->body . "\n\n" . $insert_text . "\n\n" );
            }
        }
    }
}    # end sub edit


=head2 permissions

This action allows page permissions to be displayed and edited.

=cut

sub permissions : Global {
    my ( $self, $c, $path ) = @_;

    my $stash = $c->stash;
    $stash->{template} = 'page/permissions.tt';

    my @path_elements = $c->_expand_path_elements( $stash->{path} );
    my $current_path  = pop @path_elements;

    my $data = $c->get_permissions_data( $current_path, \@path_elements );
    my $current_data =
      exists $data->{$current_path} ? $data->{$current_path} : {};

    my @roles = $c->model('DBIC::Role')->active_roles->all;
    my %roles = map { $_->id => $_->name } @roles;

    my %current;

    # build current page permissions hash for each role
    for my $role (@roles) {
        $current{ $role->name } =
          exists $current_data->{ $role->id }
          ? $current_data->{ $role->id }
          : undef;
    }

    # same as above: sort elements to avoid nasty TT code
    $stash->{current_perms} = [
        map {
            {
                role_name => $_,
                inherited => $current{$_} ? 1 : 0,
                perms => $current{$_} && $current{$_}->{page},
                subpages => exists $current{$_}->{subpages}
                ? 1
                : 0
            }
          }
          sort keys %current
    ];

    my %inherited;
    my $parent_path = $path_elements[-1];

    # build inherited permissions hash
    for my $path ( keys %$data ) {

        # might have additional data (if cached)
        next unless ($parent_path && $parent_path =~ /^$path/);
        next if $path eq $current_path;
        my $path_perms = $data->{$path};
        for my $role ( keys %$path_perms ) {
            next unless exists $roles{$role};
            my $role_perms = $path_perms->{$role};
            $inherited{$path}{ $roles{$role} } = $role_perms->{subpages}
              if exists $role_perms->{subpages};
        }
    }

    # sort elements to avoid nasty TT code
    $stash->{inherited_perms} = [
        map { { path => $_, perms => $inherited{$_} } }
          sort { length $a <=> length $b } keys %inherited
    ];
}

=head2 rollback

This action will revert a page to a older revision.

=cut

sub rollback : Global {
    my ( $self, $c, $page ) = @_;
    if ($c->req->method ne 'POST') {
        # general error - we want a POST
        $c->res->status(400);
        $c->detach('unauthorized', [$c->loc('rollback')]);
    }

    if ( $c->req->param('rev') ) {
        # TODO this needs to do a proper versioned rollback, via
        # $page->add_version( content_version => $c->req->param('rev')
        # The problem is that the page_version table doesn't have a content_version field
        # We could cannibalize the parent_version field, which is dummily always '1'
        $c->stash->{page}->content_version( $c->req->param('rev') );
        $c->stash->{page}->update;
        undef $c->req->params->{rev};
        $c->forward('/page/view');
    }
}

=head2 title ( .info/title )

AJAX method for renaming a page. Creates a new 
L<PageVersion|MojoMojo::Schema::Result::PageVersion> with the rename,
so that the renaming itself could in the future be shown in the page
history.

=cut

sub title : Path('/info/title') {
    my ( $self, $c ) = @_;
    my $page = $c->stash->{page};
    my $user_id = $c->user_exists ? $c->user->obj->id : 1;  # Anon edit
    
    if ($c->req->method ne 'POST') {
        # general error - we want a POST
        $c->res->status(400);
        $c->detach('unauthorized', [$c->loc('rename via non-POST method')]);
    }
    
    if ( $c->req->param('update_value') ) {
        my $page_version_new = $page->add_version(
            creator => $user_id,
            name_orig => $c->req->param('update_value'),
        );
        $c->res->body( $page_version_new->name_orig );
    } else {
        # User attempted to rename the page to ''. Deny that.
        $c->res->body( $page->name_orig );
    }    
    
}
=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
