package MojoMojo::Plugin::DefaultAuth;

=head1 NAME

MojoMojo::Plugin::DefaultAuth - Default authen/authz class for MojoMojo.

=head1 DESCRIPTION

This is the default authentication and authorization class for MojoMojo. It's implemented as a plugin
in order to allow users to define their own classes to perform these services. User defined auth plugins
must implement all of the actions in this interface.

=head1 ACTIONS

=over 4

=item login (/.login)

Either authenticate a user through login/pass params, or display the login screen.

=cut

sub login {
    my ( $self, $c ) = @_;
    $c->stash->{message} = 'please enter username & password';
    if ( $c->req->params->{login} ) {
        $c->session_login( $c->req->params->{login}, $c->req->params->{pass} );
        if ( $c->stash->{user}=MojoMojo::M::Core::Person->get_user(
                $c->req->{user} ) ) {
            $c->res->redirect($c->stash->{user}->link)
                unless $c->stash->{template};
            return;
        }
        else {
            $c->stash->{message} = 'could not authenticate that login.';
        }
    }
    $c->stash->{template} ||= "user/login.tt";
}

=item logout (/.logout)

Deletes this user's cookie and clears his session.

=cut

sub logout {
    my ( $self, $c ) = @_;
    $c->session_logout;
    undef $c->stash->{user};
    $c->forward('/page/view');
}

=back

=head1 AUTHORS

David Naughton <naughton@cpan.org>, Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
