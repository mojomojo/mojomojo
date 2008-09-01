package MojoMojo::Controller::Admin;

use strict;
use base 'Catalyst::Controller';

=head1 NAME

MojoMojo::Controller::Admin - Catalyst component

=head1 DESCRIPTION

Catalyst admin controller

=head1 METHODS

=over 4

=item auto

Only administrators should access functions in this controller

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

sub default : Private {
    my ( $self, $c ) = @_;
    my $admins = $c->pref('admins');
    my $user   = $c->stash->{user}->login;
    $admins =~ s/\b$user\b//g;
    $c->stash->{template}       = 'settings.tt';
    $c->stash->{admins}         = $admins;
    $c->stash->{anonymous_user} = $c->pref('anonymous_user');
}

=item update ( .admin/update )

Update system settings.

=cut

sub update : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'settings.tt';
    $c->form(
        required => [qw/name/],
        optional => [qw/admins anonymous_user registration restricted/]
    );
    if ( $c->form->has_missing ) {
        $c->stash->{message} =
            "Can't update, missing fields:" . join( ', ', $c->form->missing() ) . '</b>';
        return;
    }
    my @users = split( m/\s+/, $c->form->valid('admins') );
    foreach my $user (@users) {
        unless ( $c->model("DBIC::Person")->get_user($user) ) {
            $c->stash->{message} = 'Cant find admin user: ' . $user;
            return;
        }
    }

    # FIXME: Needs refactor
    if ( $c->form->valid('registration') ) {
        $c->pref( 'open_registration', 1 );
    }
    else {
        $c->pref( 'open_registration', 0 );
    }
    if ( $c->form->valid('restricted') ) {
        $c->pref( 'restricted_user', 1 );
    }
    else {
        $c->pref( 'restricted_user', 0 );
    }
    $c->pref( 'admins', join( ' ', @users, $c->stash->{user}->login ) );
    $c->pref( 'name', $c->form->valid('name') );
    $c->pref( 'anonymous_user', $c->form->valid('anonymous_user') || '' );

    $c->stash->{message} = "Updated successfully.";
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
