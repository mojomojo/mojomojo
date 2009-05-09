package MojoMojo::Controller::Admin;

use strict;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

MojoMojo::Controller::Admin - Site Administration

=head1 DESCRIPTION
 
Action to handle management of MojoMojo. Click the admin link at the 
bottom of the page while logged in as admin to access these functions. 


=head1 METHODS

=over 4

=item auto

Access control. Only administrators should access functions in this controller

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    my $user = $c->stash->{user};
    unless ( $user && $user->is_admin ) {
        $c->stash->{message}  = $c->loc('Restricted area. Admin access required');
        $c->stash->{template} = 'message.tt';
        return 0;
    }
    return 1;
}

=item settings ( /.admin )

Show settings screen.

=cut

sub settings : Path FormConfig Args(0) {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};
    my $user = $c->stash->{user}->login;
   
    my $admins = $c->pref('admins');
    $admins =~ s/\b$user\b//g;
    my $select_theme = $form->get_all_element({name => 'theme'});
    my @themes;
    foreach my $theme (MojoMojo::Model::Themes->list){
        push @themes,[$theme,$theme]; 
    };
    $select_theme->options(\@themes);
    unless( $form->submitted ) {
        $form->default_values({
            name                     => $c->pref('name'),
            admins                   => $admins,
            anonymous_user           => $c->pref('anonymous_user'),
            open_registration        => $c->pref('open_registration'),
            restricted_user          => $c->pref('restricted_user'),
            disable_search           => $c->pref('disable_search'),
            enable_emoticons         => $c->pref('enable_emoticons'),
            check_permission_on_view => $c->pref('check_permission_on_view'),
            cache_permission_data    => $c->pref('cache_permission_data'),
            enforce_login            => $c->pref('enforce_login'),
            create_allowed           => $c->pref('create_allowed'),
            delete_allowed           => $c->pref('delete_allowed'),
            edit_allowed             => $c->pref('edit_allowed'),
            view_allowed             => $c->pref('view_allowed'),
            attachment_allowed       => $c->pref('attachment_allowed'),
            use_captcha              => $c->pref('use_captcha'),
            theme                    => $c->pref('theme'),
            main_formatter           => $c->pref('main_formatter')
        });
        $form->process();
        return;
    }
    my @users = split( m/\s+/, $form->params->{admins} );
    foreach my $user (@users) {
        unless ( $c->model("DBIC::Person")->get_user($user) ) {
            $c->stash->{message} = $c->loc('Cant find admin user: ') . $user;
            return;
        }
    }
    $c->pref( 'check_permission_on_view', $form->params->{check_permission_on_view} ?1:0 );
    $c->pref( 'cache_permission_data',    $form->params->{cache_permission_data}    ?1:0 );
    $c->pref( 'open_registration',        $form->params->{open_registration}        ?1:0 );
    $c->pref( 'restricted_user',          $form->params->{restricted_user}          ?1:0 );
    $c->pref( 'use_captcha',              $form->params->{use_captcha}              ?1:0 );
    $c->pref( 'disable_search',           $form->params->{disable_search}           ?1:0 );
    $c->pref( 'enable_emoticons',         $form->params->{enable_emoticons}         ?1:0 );
    $c->pref( 'enforce_login',            $form->params->{enforce_login}            ?1:0 );
    $c->pref( 'create_allowed',           $form->params->{create_allowed}           ?1:0 );
    $c->pref( 'delete_allowed',           $form->params->{delete_allowed}           ?1:0 );
    $c->pref( 'edit_allowed',             $form->params->{edit_allowed}             ?1:0 );
    $c->pref( 'view_allowed',             $form->params->{view_allowed}             ?1:0 );
    $c->pref( 'attachment_allowed',       $form->params->{attachment_allowed}       ?1:0 );

    $c->pref( 'admins',         join( ' ', @users, $c->stash->{user}->login ) );
    $c->pref( 'name',           $form->params->{name} );
    $c->pref( 'anonymous_user', $form->params->{anonymous_user} || '' );
    $c->pref( 'theme',          $form->params->{theme} || 'default' );
    $c->pref( 'main_formatter', $form->params->{main_formatter} );

    $c->stash->{message} = $c->loc("Updated successfully.");
}

=item user ( .admin/user )

User listing with pager, for enabling/disabling users.

=cut

sub user : Local {
    my ( $self, $c, $user ) = @_;
    my $iterator = $c->model("DBIC::Person")->search(
        {},
        {
            page => $c->req->param('page') || 1,
            rows => 20,
            order_by => 'active, login'
        }
    );
    $c->stash->{users} = $iterator;
    $c->stash->{pager} = $iterator->pager;
}

=item role ( .admin/role )

Role listing, creation and assignment.

=cut

sub role : Local Args(0) {
    my ($self, $c) = @_;
    $c->stash->{roles} = [ $c->model('DBIC::Role')->search(undef,{order_by=>['id asc']}) ];
}

=item create_role ( .admin/create_role )

Role creation page.

=cut

sub create_role : Local Args(0) FormConfig('admin/role_form.yml')  {
    my ($self, $c) = @_;
    $c->forward('handle_role_form');
}

=item edit_role ( .admin/role/ )

Role edit page.

=cut

sub edit_role : Path('role') Args(1) FormConfig('admin/role_form.yml') {
    my ($self, $c, $role_name) = @_;
    my $form = $c->stash->{form};

    my $role = $c->model('DBIC::Role')->find( { name => $role_name } );
    
    if ($role) {
        # load stash parameters if the page is only being displayed
        unless ( $c->forward('handle_role_form', [$role]) ) {
            $c->stash->{members} = [ $role->members->all ];
            $c->stash->{role}    = $role;
        }
    }
    else {
        $c->res->redirect( $c->uri_for('admin/role') );
    }
}

=item handle_role_form 

Handle role form processing.
Returns true when a submitted form was actually processed.

=cut

sub handle_role_form : Private {
    my ($self, $c, $role) = @_;
    my $form = $c->stash->{form};

    if ( $form->submitted_and_valid ) {
        my $params = $form->params;

        my $fields = {
            name   => $params->{name},
            active => ( $params->{active} ? 1 : 0 )
        };

        # make sure updating works
        $fields->{id} = $role->id if $role;
        
        $role = $c->model('DBIC::Role')->update_or_create( $fields );

        if ($role) {
            # in order to safely update the role members, they're removed and
            # then reinserted - this is a bit inefficient but updating role 
            # members shouldn't be a frequent operation
            $role->role_members->delete;
            
            if ($params->{role_members}) {
                my @role_members = 
                    ref $params->{role_members} eq 'ARRAY' ? 
                        @{$params->{role_members}} : $params->{role_members};

                for my $person_id (@role_members) {
                    $role->add_to_role_members( { 
                        person => $person_id, 
                        admin  => 0 
                    });
                }
            }

            $c->res->redirect( $c->uri_for('admin/role') );
        }
        
        return 1;
    }
}

=item update_user ( *private*)

Update user based on user listing.

=cut

sub update_user : Local {
    my ( $self, $c, $user ) = @_;
    $user = $c->model("DBIC::Person")->find($user) || return;

    #  if ($action eq 'active') {
    $user->active( !$user->active );

    #  }
    $user->update;
    $c->stash->{user} = $user;
}

=back


=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
