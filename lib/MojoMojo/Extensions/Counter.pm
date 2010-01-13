package MojoMojo::Extensions::Counter;

use strict;
use warnings;

use base qw(MojoMojo::Extension); # ISA Catalyst::Controller

sub index :Path('counter') :Args(0) {
    my ( $self, $c ) = @_;

    $c->detach('view');
}

sub view :Path('counter.view') :Args(0) {
    my ( $self, $c ) = @_;
    @{$c->stash}{qw(current_view template count)} = ('TT', 'extensions/counter.tt', $c->session->{count} || 0);
}

sub add :Path('counter.add') :Args(0) {
    my ( $self, $c ) = @_;

    my $session = $c->session;
    my $count = $session->{count} || 0;
    $session->{count} = $count + 1;

    $c->res->redirect($c->uri_for('/special/counter'));
}

sub subtract :Path('counter.subtract') :Args(0) {
    my ( $self, $c ) = @_;

    my $session = $c->session;
    my $count = $session->{count} || 0;
    $session->{count} = $count - 1;

    $c->res->redirect($c->uri_for('/special/counter'));
}

1;
