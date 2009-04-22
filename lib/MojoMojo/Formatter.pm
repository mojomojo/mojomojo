package MojoMojo::Formatter;

sub primary_formatter { 0; }

sub module_loaded { 1; }

sub gen_re {
    my ($self,$tag,$args)=@_;
    $args ||= '';
    return qr{\{\{\s*$tag\s*$args\s*\}\}};
}



=head1 NAME

MojoMojo::Formatter - Base class for all formatters

=head1 SYNOPSIS

    package MojoMojo::Formatter::Simple;
    
    use parent qw/MojoMojo::Formatter/;
    
    sub format_content_order { 1 } 
    
    sub format_content {
        my ($class,$content,$c)=@_;
        $$content =~ s/fuck/f**k/g;
        return $content;
    }
    

=head1 DESCRIPTION

This is the class to inherit from if you want to write your own formatter.


=head1 WRITING YOUR OWN FORMATTER

See the synopsis for a really simple formatter example. MojoMojo uses 
L<Module::Pluggable::Ordered> to process all the formatter plugins. Just 
specify when you want to trigger your formatter by providing a format_content_order
method which returns a number to specify when you want to run. The  plugin order 
for the default plugins is currently as follows:

=over 4

=item 1  - L<MojoMojo::Formatter::Redirect> - handles =redirect

=item 6  - L<MojoMojo::Formatter::Include> - handles =http://<url>

=item 7  - L<MojoMojo::Formatter::Scrub> - Removes harmful HTML

=item 10 - L<MojoMojo::Formatter::Wiki> - Handles [[wikiwords]]

=item 10 - L<MojoMojo::Formatter::Pod> - handles =pod ... =pod blocks

=item 14 - L<MojoMojo::Formater::IRCLog> - handles =irc ... =irc blocks

=item 15 - Main formatter (either L<MojoMojo::Formatter::Textile> or L<MojoMojo::Formatter::Markdown>)

=item 91 - L<MojoMojo::Formatter::Comment> Handles =comments , inserts a comment box

=item 95 - L<MojoMojo::Formatter::TOC> replace =toc with table of contents

=item 99  - L<MojoMojo::Formatter::SyntaxHighlight> - Performs syntax highlighting on code blocks

=back

Note that if your formatter expects a HTML body, it should run after the
main formatter.

If you want your formatter to do something, you also need to override format_content.
it get's passed it's classname, a scalar ref to the content, and the context object.
it should return the scalarref.

=head1 METHODS

You can also override further methods to your formatter:

=head2 primary_formatter

Primary formatters are those who handle the basic job of translating markup to HTML. 
In the default distribution there are currently two, Textile and Markdown, with Textile
being the default setting. You can change this through Prefs. Override this method to
return 1 to contend for as a primary formatter. Note that primary formatters should 
run at 15.


=head1 SEE ALSO

L<MojoMojo>,L<MojoMojo::Formatter::Textile>,L<MojoMojo::Formatter::Markdown>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
