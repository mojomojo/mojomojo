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

sub logout : Global {
    my ( $self, $c ) = @_;
    $c->session_logout;
    $c->forward('/page/view');
}

=item login (/.login)

authorize a user through login/pass params, or display login
screen otherwise.

=cut

sub login : Global {
    my ( $self, $c ) = @_;
    $c->stash->{message} = 'please enter username & password';
    if ( $c->req->params->{login} ) {
        $c->session_login( $c->req->params->{login}, $c->req->params->{pass} );
        if ( $c->req->{user} ) {
            $c->forward('/page/view') unless $c->stash->{template};
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

sub users : Global { 
  my ( $self, $c ) = @_;
  $c->stash->{users}=MojoMojo::M::Core::Person->retrieve_all();
  $c->stash->{template} = 'user/list.tt'
}

=item prefs

Main user preferences screen.

=cut

sub prefs : Global {
    my ( $self, $c ) = @_;
    $c->stash->{template}='user/prefs.tt';
    $c->stash->{user}=MojoMojo::M::Core::Person->get_user($c->stash->{page}->name);
    unless ($c->stash->{user}) {
      $c->stash->{message}='Cannot find that user';
      $c->stash->{template}='message.tt';
    };
}

sub password : Path('/prefs/password') {
    my ( $self, $c ) = @_;
    $c->forward('prefs');
    return if $c->stash->{message};
    $c->stash->{template}='user/password.tt';
    $c->form(
      required=>[qw/current pass again/]
      );
    unless ( $c->form->has_missing || $c->form->has_invalid ) {
      if ($c->form->valid('again') ne $c->form->valid('pass')) {
        $c->stash->{message}='Passwords did not match.';
        return
      }
      #FIXME: need to verify current password.
      $c->stash->{user}->pass($c->form->valid('pass'));
      $c->stash->{user}->update();
      $c->stash->{message}='Your password has been updated';
    }
    $c->stash->{message} ||= 'please fill out all fields';
}
=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
