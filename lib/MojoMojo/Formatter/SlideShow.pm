package MojoMojo::Formatter::SlideShow;

use base qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::Slideshow - Include slideshows on your page.

=head1 DESCRIPTION


This formatter allows you to embed a slideshow of the current page's
gallery into the content.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Comment formatter runs on 91

=cut

sub format_content_order { 92 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c, $self ) = @_;
    eval {
        $$content =~ s{\<p\>\=slideshow\s*\<\/p\>}
                  {show_slide($c,$c->stash->{page})}me;
    };
}

=item show_comments


=cut

sub show_slide {
    my ( $c, $page ) = @_;
    return '<div id="slide">' . $c->view('TT')->render( $c, 'slideshow.tt' ) . '</div>';
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
