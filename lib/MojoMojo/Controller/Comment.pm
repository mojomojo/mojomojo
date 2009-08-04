package MojoMojo::Controller::Comment;

use strict;

use parent 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

MojoMojo::Controller::Comment - MojoMojo Comment controller

See L<MojoMojo>

=head1 DESCRIPTION

Controller for Page comments.

=head1 METHODS

=head2 comment

display comments for embedding in a page

=cut

sub comment : Global FormConfig {
    my ( $self, $c ) = @_;
    my $form=$c->stash->{form};
    $c->stash->{template} = 'comment.tt';

    if ( $c->stash->{user} && $form->submitted_and_valid) {
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

=head2 login ( .comment/login )

Inline login for comments.

=cut

sub login : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'comment/post.tt';
    $c->forward('/user/login');
    if ( $c->stash->{fail} ) {
        $c->stash->{template} = 'comment/login.tt';
    }
}

=head2 remove ( .comment/remove )

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

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
