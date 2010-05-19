package MojoMojo::Extensions::Counter;

use strict;
use warnings;

use base qw(MojoMojo::Extension); # ISA Catalyst::Controller

=head1 Name

MojoMojo::Extensions::Counter - a page counter

=head2 Methods

=head2 index

View page.

=cut

sub index :Path('counter') :Args(0) {
    my ( $self, $c ) = @_;

    $c->detach('view');
}

=head2 view

Add count into the view.

=cut

sub view :Path('counter.view') :Args(0) {
    my ( $self, $c ) = @_;
    @{$c->stash}{qw(current_view template count)} = ('TT', 'extensions/counter.tt', $c->session->{count} || 0);
}

=head2 add

Increment count by 1.

=cut

sub add :Path('counter.add') :Args(0) {
    my ( $self, $c ) = @_;

    my $session = $c->session;
    my $count = $session->{count} || 0;
    $session->{count} = $count + 1;

    $c->res->redirect($c->uri_for('/special/counter'));
}

=head2 subtract

Reduce count by 1.

=cut

sub subtract :Path('counter.subtract') :Args(0) {
    my ( $self, $c ) = @_;

    my $session = $c->session;
    my $count = $session->{count} || 0;
    $session->{count} = $count - 1;

    $c->res->redirect($c->uri_for('/special/counter'));
}

1;
