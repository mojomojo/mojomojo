package MojoMojo::C::Comment;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Comment - MojoMojo Comment controller

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

Handles everything related to the MojoMojo controller

=head1 METHODS

=over 4

=item default

display comments for embedding

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template}='comment.tt';
    $c->form(
    required=>[qw/body/],
    defaults => {
      page=>$c->stash->{page},
      poster=>$c->stash->{user},
      posted=>DateTime->now(),
    }
    );
    unless (! $c->stash->{user} || $c->form->has_missing || $c->form->has_invalid) {
            MojoMojo::M::Core::Comment->create_from_form($c->form);
    }
    $c->stash->{comments} = MojoMojo::M::Core::Comment->find_page($c->stash->{page}, {order_by=>'posted'});
}

=item login

=cut

sub login : Local {
    my ( $self, $c ) = @_;
    $c->forward('/user/login');
    if ($c->stash->{message}) {
        $c->stash->{template}='comment/login.tt';
    } else {
        $c->stash->{template}='comment/post.tt';
    }
}

sub remove : Local {
    my ( $self, $c, $comment ) = @_;
    if ($comment=MojoMojo::M::Core::Comment->retrieve($comment)) {
        if ( $comment->page->id == $c->stash->{page}->id &&
             $c->stash->{user}->can_edit($comment->page)) {
            $comment->delete();
        }
    }
    $c->forward('/page/view');

}

=cut

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
