package MojoMojo::Formatter::Right;

use base qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::Gmap - Include gmap on your page.

=head1 DESCRIPTION

This is a hook for the page gmap functionality. It allows a
gmap box to be placed anywhere on your page through the =gmap
tag.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Comment formatter runs on 91

=cut

sub format_content_order { 101 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c, $self ) = @_;
    eval {
        $$content =~ s{\<p\>\=right\((.*)\)\s*\<\/p\>}
                  {show_right($c,$c->stash->{page},$1)}me;
    };
}

=item show_gmap

Draw GMAP.

=cut

sub show_right {
    my ( $c, $page,$content ) = @_;
    $c->stash->{nb_column} = $content;
    return $c->view('TT')->render( $c, 'custom/default_right.tt' );

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
