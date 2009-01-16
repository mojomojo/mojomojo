package MojoMojo::Formatter::CustomTemplate;

use base qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::Comment - Include comments on your page.

=head1 DESCRIPTION

This is a hook for the page comment functionality. It allows a
comment box to be placed anywhere on your page through the =comments
tag.

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
    my ($class,$content,$c,$self) = @_;
    my (@newlines);
    eval {
    $$content =~ s{<p\>\=templatecustom\((.*)\)\s*\<\/p\>}
                  {show_template($c,$c->stash->{page},$1)}ge;
    };
}

=item show_comments

Redispatches a subrequest to L<MojoMojo::Controller::Comment>.

=cut

sub show_template {
    my ( $c, $page,$template ) = @_;
    return  $c->view('TT')->render($c,'custom/' . $template);
}

=back

=head1 SEE ALSO

L<MojoMojo::Pluggable::Ordered>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
