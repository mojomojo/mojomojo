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
        $c->stash->{message}  = 'Sorry bubba, gotta be admin';
        $c->stash->{template} = 'message.tt';
        return 0;
    }
    return 1;
}

=item  default ( /.admin )

Show settings screen.

=cut


sub settings : Path FormConfig Args(0) {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};
    my $user = $c->stash->{user}->login;
   
    my $admins = $c->pref('admins');
    $admins =~ s/\b$user\b//g;

    unless( $form->submitted ) {
        $form->default_values({
            name              => $c->pref('name'),
            admins            => $admins,
            anonymous_user    => $c->pref('anonymous_user'),
            open_registration => $c->pref('open_registration'),
            restricted_user   => $c->pref('restricted_user'),
        });
        $form->process();
    }
    elsif ( $form->submitted_and_valid ) {
        my @users = split( m/\s+/, $form->params->{admins} );
        foreach $user (@users) {
            unless ( $c->model("DBIC::Person")->get_user($user) ) {
                $c->stash->{message} = 'Cant find admin user: ' . $user;
                return;
            }
        }
        # FIXME: Needs refactor
        $c->pref( 'name', $form->params->{name} );
        $c->pref( 'admins', join( ' ', @users, $c->stash->{user}->login ) );
        $c->pref( 'open_registration', $form->params->{open_registration} );
        $c->pref( 'restricted_user', $form->params->{restricted_user} );
        $c->pref( 'anonymous_user', $form->params->{anonymous_user} || '' );
        $c->stash->{message} = "Updated successfully.";
    }
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
    $c->stash->{roles} = [ $c->model('DBIC::Role')->all ];
}

=item create_role ( .admin/create_role )

Role creation page.

=cut

sub create_role : Local Args(0)  {
    my ($self, $c) = @_;
    my $form = $c->stash->{form};

    if ( $c->req->param('submit') ) {
        my $name   = $c->req->param('name');
        my $active = $c->req->param('active') ? 1 : 0;
        
        my $role = $c->model('DBIC::Role')->create( {
            name   => $name,
            active => $active
        } );

        if ($role) {        
            $c->res->redirect( $c->uri_for('admin/role') );
        }
    }
}

=item edit_role ( .admin/role/ )

Role edit page.

=cut

sub edit_role : Path('role') Args(1) {
    my ($self, $c, $role_name) = @_;
    my $role = $c->model('DBIC::Role')->find( { name => $role_name } );
    
    if ($role) {
        if ( $c->req->param('submit') ) {
            $role->update( {
                name   => $c->req->param('name'),
                active => $c->req->param('active') ? 1 : 0
            } );
            
            # update roles
            $role->role_members->delete;

            for my $person_id ($c->req->param('role_members')) {
                $role->add_to_role_members( { person => $person_id, admin => 0 } );
            }

            $c->res->redirect( $c->uri_for('admin/role') );
        }
        else {
            $c->stash->{members} = [ $role->members->all ];
            $c->stash->{role}    = $role;
        }
    }
    else {
        $c->res->redirect( $c->uri_for('admin/role') );
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
