package MojoMojo::Controller::Comment;

use strict;

use base 'Catalyst::Controller';

=head1 NAME

MojoMojo::Controller::Comment - MojoMojo Comment controller

See L<MojoMojo>

=head1 DESCRIPTION

Controller for Page comments.

=head1 METHODS

=over 4

=item default

display comments for embedding in a page

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'comment.tt';
    $c->form(
        required => [qw/body/],
        defaults => {
            page   => $c->stash->{page},
            poster => $c->stash->{user},
            posted => DateTime->now(),
        }
    );
    unless ( !$c->stash->{user}
        || $c->form->has_missing
        || $c->form->has_invalid )
    {
        $c->model("DBIC::Comment")->create(
            {
                page   => $c->stash->{page}->id,
                poster => $c->stash->{user}->id,
                posted => DateTime->now(),
                body   => $c->req->param('body'),
            }
        );
    }
    $c->stash->{comments} =
        $c->model("DBIC::Comment")
        ->search( { page => $c->stash->{page}->id }, { order_by => 'posted' } );
}

=item login (.comment/login)

inline login for comments.

=cut

sub login : Local {
    my ( $self, $c ) = @_;
    $c->forward('/user/login');
    if ( $c->stash->{message} ) {
        $c->stash->{template} = 'comment/login.tt';
    }
    else {
        $c->stash->{template} = 'comment/post.tt';
    }
}

=item remove (.comment/remove)

Remove comments, provided user can edit the page the comment is on.

=cut

sub remove : Local {
    my ( $self, $c, $comment ) = @_;
    if ( $comment = $c->model("DBIC::Comment")->find($comment) ) {
        if (   $comment->page->id == $c->stash->{page}->id
            && $c->stash->{user}->can_edit( $comment->page->path ) )
        {
            $comment->delete();
        }
    }
    $c->forward('/page/view');

}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
