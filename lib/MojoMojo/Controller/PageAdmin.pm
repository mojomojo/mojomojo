package MojoMojo::Controller::PageAdmin;
use warnings;
use strict;
use Data::Dumper;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

MojoMojo::Controller::PageAdmin - MojoMojo Page Administration

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

methods for administration of pages.

=head1 METHODS

=head2 auto

Check that user is logged in and has rights to this page.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->forward('/user/login')
        if $c->req->params->{pass}
            && !$c->stash->{user};

    # everyone can edit with anon mode enabled.
    return 1 if MojoMojo->pref('anonymous_user');
    my $user = $c->stash->{user};
    return 1 if $user && $user->can_edit( $c->stash->{path} );
    return 1 if $user && !$c->pref('restricted_user');
    $c->stash->{template} = 'message.tt';
    $c->stash->{message}  = 'Sorry bubba, you aint got no rights to this page';
    return 0;
}

=head2 edit

This action will display the edit form, then save the previous
revision, and create a new based on the posted content.
after saving, it will forward to the highlight action.

=cut

sub edit : Global FormConfig {
    my ( $self, $c, $path ) = @_;

    # Set up the basics. Log in if there's a user.
    my $form=$c->stash->{form};
    my $stash = $c->stash;
    $stash->{template} = 'page/edit.tt';

    my $user = $c->user_exists ? $c->user->obj->id : 1;    # Anon edit

    my ( $path_pages, $proto_pages ) = @$stash{qw/ path_pages proto_pages /};

    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages) {
        ( $path_pages, $proto_pages ) = $c->model('DBIC::Page')->path_pages($path);
    }

    # the page we're editing is at the end of either path_pages or
    # proto_pages, # depending on whether or not the page already exists
    my $page = (
        @$proto_pages > 0
        ? $proto_pages->[ @$proto_pages - 1 ]
        : $path_pages->[ @$path_pages - 1 ]
    );

    # this should never happen!
    die "Cannot determine what page to edit for path: $path" unless $page;
    @$stash{qw/ path_pages proto_pages /} = ( $path_pages, $proto_pages );


    my $perms =
        $c->check_permissions( $stash->{'path'}, ( $c->user_exists ? $c->user->obj : undef ) );
    my $permtocheck = ( @$proto_pages > 0 ? 'create' : 'edit' );
    if ( !$perms->{$permtocheck} ) {
        my $name = ref($page) eq 'HASH' ? $page->{name} : $page->name;
        $stash->{'message'}  = 'Permission Denied to ' . $permtocheck . ' ' . $name;
        $stash->{'template'} = 'message.tt';
        return;
    }
    if ( $user == 1 && !$c->pref('anonymous_user') ) {
        $c->stash->{message} ||= 'Anonymous Edit disabled';
        return;
    }

    if ( $form->submitted_and_valid ) {

        my $valid = $form->params;
        $valid->{creator} = $user;

        if (@$proto_pages) {   # page doesn't exist yet
            
            $path_pages = $c->model('DBIC::Page')->create_path_pages(
                    path_pages  => $path_pages,
                    proto_pages => $proto_pages,
                    creator     => $user,
            );
            $page = $path_pages->[ @$path_pages - 1 ];
        }
        $c->model("DBIC::Page")->set_paths(@$path_pages);
        $page->update_content( %$valid );

        # update the search index with the new content
        $c->model("DBIC::Page")->set_paths($page);
        $c->model('Search')->index_page($page) unless $c->pref('disable_search');
        $page->content->store_links();

        $c->res->redirect( $c->uri_for( $c->stash->{path}) );   
    }
    else {
        # if we have missing or invalid fields, display the edit form.
        # this will always happen on the initial request
        $stash->{page} = $page;

        # Note that this isn't a real Content object, just a proto object!!!
        # It's just a hash, not blessed into the Content package.
        $stash->{content}            = $c->model("DBIC::Content")->create_proto($page);
        $stash->{content}->{creator} = $user;
        $c->req->params->{body}      = $stash->{content}->{body}
        unless $c->req->params->{body};
        return;
    }
}    # end sub edit

=head2 permissions

This action allows page permissions to be displayed and edited.

=cut

sub permissions : Global {
    my ($self, $c, $path) = @_;
    
    my $stash = $c->stash;
    $stash->{template} = 'page/permissions.tt';

    my @path_elements = $c->_expand_path_elements($stash->{path});
    my $current_path = pop @path_elements;
    
    my $data = $c->get_permissions_data( $current_path, \@path_elements );
    my $current_data = exists $data->{$current_path} ? $data->{$current_path} : {};

    my @roles = $c->model('DBIC::Role')->active_roles->all;
    my %roles = map { $_->id => $_->name } @roles;

    my %current;
    
    # build current page permissions hash for each role
    for my $role (@roles) {
        $current{$role->name} = 
            exists $current_data->{$role->id} ? 
                $current_data->{$role->id} : undef;
    }

    # same as above: sort elements to avoid nasty TT code
    $stash->{current_perms} = [ 
        map { { 
            role_name => $_, 
            inherited => $current{$_} ? 1 : 0,
            perms     => $current{$_} && $current{$_}->{page}, 
            subpages  => exists $current{$_}->{subpages} ? 1 : 0
        } } 
        sort keys %current
    ];

    my %inherited;
    my $parent_path = $path_elements[-1];

    # build inherited permissions hash
    for my $path (keys %$data) {
        # might have additional data (if cached)
        next unless ($parent_path && $parent_path =~ /^$path/);

        my $path_perms = $data->{$path};
        for my $role (keys %$path_perms) {
            next unless exists $roles{$role};
            my $role_perms = $path_perms->{$role};
            $inherited{$path}{$roles{$role}} = $role_perms->{subpages}
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

=cut

sub rollback : Global {
    my ( $self, $c, $page ) = @_;
    if ( $c->req->param('rev') ) {
        $c->stash->{page}->content_version( $c->req->param('rev') );
        $c->stash->{page}->update;
        undef $c->req->params->{rev};
        $c->forward('/page/view');
    }
}

sub delete : Global {
    my ( $self, $c, $page ) = @_;
    $c->stash->{page}->delete;
    $c->forward('/page/view');
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
