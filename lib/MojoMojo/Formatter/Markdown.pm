package MojoMojo::Formatter::Markdown;

use base qw/MojoMojo::Formatter/;


my $markdown;
eval "use Text::MultiMarkdown";
unless ($@) {
    $markdown = Text::MultiMarkdown->new(
        markdown_in_html_blocks => 1, # Allow Markdown syntax within HTML blocks.
        use_metadata => 0, # Remove MultiMarkdown behavior change to make the top of the document metadata.
        heading_ids  => 0, # Remove MultiMarkdown behavior change in <hX> tags.
        img_ids      => 0, # Remove MultiMarkdown behavior change in <img> tags.
    );
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
    # Let markdown handle the rest
    $$content= $markdown->markdown( $$content );
}

=back 

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<Text::MultiMarkdown>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
