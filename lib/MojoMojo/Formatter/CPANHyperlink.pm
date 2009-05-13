package MojoMojo::Formatter::CPANHyperlink;

use parent qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::CPANHyperlink - automatically hyperlink CPAN modules when
using the syntax {{cpan Some::Module}}

=head1 DESCRIPTION

Normally, to hyperlink to a CPAN module, you'd write:

    [MojoMojo::Formatter::CPANHyperlink](http://search.cpan.org/perldoc?MojoMojo::Formatter::CPANHyperlink)

This plugin lets you write just

    {{cpan MojoMojo::Formatter::CPANHyperlink}}


=head1 METHODS

=over 4

=item format_content_order

The CPANHyperlink formatter has no special requirements in terms of the order
it gets run in, so it has a priority of 10.

=cut

sub format_content_order { 10 }

=item format_content

Calls the formatter. Takes a ref to the content as well as the context object.
The syntax for the CPANHyperlink plugin invocation is:

    {{cpan Some::Module}}

In anticipation of future plugin syntax, you can optionally add a trailing slash

    {{cpan Some::Module /}}

=cut

sub format_content {
    my ( $class, $content ) = @_;

    my $component = qr/(?:[_[:alpha:]]\w*)/;
    my $cpan_params_RE = qr/$component (?: ::$component )*/x;

    $$content =~ s[
        {{cpan \s+ ($cpan_params_RE) \s* \/? }}
    ]  [<a href="http://search.cpan.org/perldoc?$1" class="external">$1</a>]ixg;
}


=back

=head1 SEE ALSO

L<MojoMojo> and L<Module::Pluggable::Ordered>.

=head1 AUTHORS

Dan Dascalescu, L<http://dandascalescu.com>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
