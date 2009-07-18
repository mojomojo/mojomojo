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

Just like POD, it supports adding a section after the module name:

    {{cpan Catalyst::Manual::Cookbook/Deployment}}

will create a link to

    http://search.cpan.org/perldoc?Catalyst::Manual::Cookbook#Deployment

Sections can contain any characters, except two consecutive closed braces:

    {{cpan Catalyst::Test/($res, $c) = ctx request( ... ); }}

will link to

    http://search.cpan.org/perldoc?Catalyst::Test#($res,_$c)_=_ctx_request(_..._);

In anticipation of future plugin syntax, you can optionally add a trailing slash

    {{cpan Some::Module/Section /}}

=head1 METHODS

=over 4

=item format_content_order

The CPANHyperlink formatter has no special requirements in terms of the order
it gets run in, so it has a priority of 10.

=cut

sub format_content_order { 10 }

=item format_content

Calls the formatter. Takes a ref to the content as well as the context object.

=cut

sub format_content {
    my ( $class, $content ) = @_;

    my $component = qr/(?:[_[:alpha:]]\w*)/;
    my $cpan_module = qr[ $component (?: ::$component )* ]x;
    my $section = qr[ .*? (?= \s* /? }} ) ]x;

    $$content =~ s[
        {{cpan \s+ ($cpan_module) (?: / ($section))? \s* \/? }}
    ]  [
        my ($module, $section) = ($1, $2);
        if (defined $section) {
            (my $anchor=$section) =~ s/\s/_/g;
            qq(<a href="http://search.cpan.org/perldoc?$module#$anchor" class="external">$section in $module</a>)
        } else {
            qq(<a href="http://search.cpan.org/perldoc?$module" class="external">$module</a>)
        }
    ]eixg;
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
