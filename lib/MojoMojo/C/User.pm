package MojoMojo::C::User;

use strict;
use base 'Catalyst::Base';

MojoMojo->action(

    '.logout' => sub {
        my ( $self, $c ) = @_;
        $c->logout;
        $c->forward('!default');
    },
    '.login' => sub {
        my ( $self, $c ) = @_;
        $c->stash->{message}='please enter username & password';
        if ($c->req->params->{login}) {
            $c->session_login($c->req->params->{login},
                              $c->req->params->{pass} );
            if ($c->req->{user}) {
              $c->forward('!default');
            } else {
              $c->stash->{message}='could not authenticate that login.';
            }
        }
        $c->stash->{template} = "user/login.tt";
    }

);

=head1 NAME

MojoMojo::C::User - A Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
