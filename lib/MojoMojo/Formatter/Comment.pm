package MojoMojo::Formatter::Comment;

use parent qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::Comment - Include comments on your page.

=head1 DESCRIPTION

This is a hook for the page comment functionality. It allows a
comment box to be placed anywhere on your page through the {{comments}}
tag.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The Comment formatter runs on 91.

=cut

sub format_content_order { 91 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c, $self ) = @_;
    my $re=$class->gen_re('comments');
    if ( $$content =~ s|$re|show_comments($c,$c->stash->{page})|xme ) {
        # We don't want to precompile a page with comments so turn it off
        $c->stash->{precompile_off} = 1;
    }
}

=head2 show_comments

Forwards to L<MojoMojo::Controller::Comment>.

=cut

sub show_comments {
    my ( $c, $page ) = @_;
    $c->forward('/comment/comment');
    return '<div id="comments">' . $c->view('TT')->render( $c, 'comment.tt' ) . '</div>';
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
