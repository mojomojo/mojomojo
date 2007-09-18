package MojoMojo::Formatter::Markdown;

use base qw/MojoMojo::Formatter/;


my $markdown;
eval {
use Text::Markdown;

$markdown = Text::Markdown->new();
};

sub primary_formatter { 1; }

=head1 NAME

MojoMojo::Formatter::MarkDown - Texile formatting for your content

=head1 DESCRIPTION

This formatter processes content using L<Text::Markdown> This is a 
syntax for writing human-friendly formatted text.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Markdown formatter runs on 15

=cut

sub format_content_order { 15 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut


sub format_content {
    my ($class,$content,$c)=@_;
    return unless $markdown;
    return unless $c->pref('main_formatter') eq 'MojoMojo::Formatter::Markdown';
    # Let textile handle the rest
    $$content= $markdown->markdown( $$content );
}

=back 

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<Text::Markdown>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
