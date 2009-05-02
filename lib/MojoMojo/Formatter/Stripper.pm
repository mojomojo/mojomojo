package MojoMojo::Formatter::Stripper;

use base qw/MojoMojo::Formatter/;
use HTML::StripScripts::Parser();
use MojoMojo::Formatter::StripScripts();

=head1 NAME

MojoMojo::Formatter::Stripper - Strip scripts from user HTML
1
=head1 DESCRIPTION

This formatter strips out XXS script using L<HTML::StripScripts::Parser>.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Strip formatter runs at order 8
in order to catch direct user input, but trusts all subsequently
ran plugins to not output unsafe HTML.  It comes right after Scrub 
which works on both HTML and scripts.

=cut

sub format_content_order { 16 }

my $stripper = MojoMojo::Formatter::StripScripts->new(
    {
        Context     => 'Flow',
        AllowHref   => 1,
        AllowRelURL => 1,

    }
);

=item format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    return;
    $$content = $stripper->filter_html($$content);
}

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<HTML::StripScripts>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>
Mateu Hunter <mateu@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
