package MojoMojo::C::User;

use strict;
use base 'Catalyst::Base';

use Digest::MD5 qw/md5_hex/;

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
    undef $c->stash->{user};
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
            $c->stash->{user}=MojoMojo::M::Core::Person->retrieve($c->req->{user_id});
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
    my @proto=@{$c->stash->{proto_pages}};
    $c->stash->{page_user}=MojoMojo::M::Core::Person->get_user(
        $proto[0]->{name} || $c->stash->{page}->name 
    );
    unless ($c->stash->{page_user} && (
        $c->stash->{page_user}->id eq $c->stash->{user}->id ||
        $c->stash->{user}->is_admin())) {
      $c->stash->{message}='Cannot find that user '.
      $c->stash->{user}->is_admin;
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
        return;
      }
      unless ($c->stash->{user}->valid_pass($c->form->valid('pass'))) {
        $c->stash->{message}='Invalid password.';
        return;
      }
      $c->stash->{user}->pass($c->form->valid('pass'));
      $c->stash->{user}->update();
      $c->stash->{message}='Your password has been updated';
    }
    $c->stash->{message} ||= 'please fill out all fields';
}

sub register : Global {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'user/register.tt';
    $c->stash->{message}='Please fill in the following information to '.
    'register. All fields are mandatory.';
}

sub do_register : Global {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'user/register.tt';
    $c->form(required => [qw(login name pass confirm email)],
             defaults  => { active => -1 }, 
             constraints => MojoMojo::M::Core::Person->registration_profile);
    if ($c->form->has_missing) {
        $c->stash->{message}='You have to fill in all fields.'. 
        'the following are missing: <b>'.
        join(', ',$c->form->missing()).'</b>';
    } elsif ($c->form->has_invalid) {
        $c->stash->{message}='Some fields are invalid. Please '.
                             'correct them and try again:';
    } else {
        my $user=MojoMojo::M::Core::Person->create_from_form($c->form);
        $c->forward('/user/login');
        $c->pref('entropy') || $c->pref('entropy',rand);
        $c->email( header => [
                From    => $c->form->valid('email'),
                To      => $c->form->valid('email'),
                Subject => '[MojoMojo] New User Validation'
            ],
            body => 'Hi. This is a mail to validate your email address, '.
            $c->form->valid('name').'. To confirm, please click '.
            "the url below:\n\n".$c->req->base.'/.validate/'.
            $user->id.'/'.md5_hex$c->form->valid('email').$c->pref('entropy')
        );
        $c->stash->{user}=$user;
        $c->stash->{template}='user/validate.tt';
    }
}    

sub validate : Global {
    my ($self,$c,$user,$check)=@_;
    $user=MojoMojo::M::Core::Person->retrieve($user);
    if($check = md5_hex($user->email.$c->pref('entropy'))) {
        $user->active(0);
        $user->update();
        if ($c->stash->{user}) {
            $c->res->redirect($c->req->base.$c->stash->{user}->link);
        } else {
            $c->stash->{message}='Welcome, '.$user->name.' your email is validated. Please log in.';
            $c->stash->{template}='user/login.tt';
        }
        return;
    }
    $c->stash->{template}='user/validate.tt';
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
