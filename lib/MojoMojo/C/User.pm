package MojoMojo::C::User;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::User - Login/User Management Controller


=head1 DESCRIPTION

This controller allows user to Log In and Log out.


=head1 ACTIONS

=over 4

=item logout (/.logout)

deletes this users cookie, and clears his session.

=cut

sub logout : Path('/.logout') {
    my ( $self, $c ) = @_;
    $c->session_logout;
    $c->forward('/default');
}

=item login (/.login)

authorize a user through login/pass params, or display login
screen otherwise.

=cut

sub login : Path('/.login') {
    my ( $self, $c ) = @_;
    $c->stash->{message} = 'please enter username & password';
    if ( $c->req->params->{login} ) {
        $c->session_login( $c->req->params->{login}, $c->req->params->{pass} );
        if ( $c->req->{user} ) {
            $c->forward('/default') unless $c->stash->{template};
            return;
        }
        else {
            $c->stash->{message} = 'could not authenticate that login.';
        }
    }
    $c->stash->{template} ||= "user/login.tt";
}

=item users (/.users)

Show a list of the active users with a link to their page.

=cut

sub users : Path('/.users') { 
  my ( $self, $c ) = @_;
  $c->stash->{users}=MojoMojo::M::Core::Person->retrieve_all();
  $c->stash->{template} = 'user/list.tt'
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
