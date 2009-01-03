package MojoMojo::Formatter::SyntaxHighlight;

use strict;
use warnings;
use base qw/MojoMojo::Formatter/;
use Syntax::Highlight::Engine::Kate;

=head1 NAME

MojoMojo::Formatter::SyntaxHighlight - syntax highlighting for code blocks

=head1 DESCRIPTION

This formatter performs syntax highlighting on code blocks.

=head1 METHODS

=over 4

=item format_content_order

The syntax highlight formatter is based on &lt;pre&gt; tags and
therefore it's elementary to get those unchanged. So we need to run
this plugin before L<MojoMojo::Formatter::Wiki> which actually changes
those tags.

=cut

sub format_content_order { 9 }

=item format_content

This formatter uses L<Syntax::Highlight::Engine::Kate> to highlight code
syntax inside of &lt;pre&gt; tags. To let the formatter know which language
has to be highlighted, do:

 <pre lang="Perl">
   print "Hello World\n";
 </pre>

See L<Syntax::Highlight::Engine::Kate/PLUGINS> for a list of supported
languages.

=cut

sub format_content {
    my ( $class, $content ) = @_;
    
    my @blocks  = ();
    my $kate    = _kate();
    my $ph      = 0;
    my $ph_base = __PACKAGE__ . '::PlaceHolder::';

    while ( $$content =~ s/<pre(?:\s+lang=['"]*(.*?)['"]*")?>(.*?)<\/pre>/$ph_base$ph/si ) {
        my ($language, $block) = ($1, $2);
        if ($language) {
            $kate->language($language);
            $block = $kate->highlightText($block);
        }
        push @blocks, $block;
        $ph++;
    }
    
    for (my $i=0; $i<$ph; $i++) {
        $$content =~ s/$ph_base$i/<pre>$blocks[$i]<\/pre>/;
    }

    return $content;
}

sub _kate {
    return Syntax::Highlight::Engine::Kate->new(
        language      => 'Perl',
        substitutions => {
            "<"  => "&lt;",
            ">"  => "&gt;",
            "&"  => "&amp;",
            " "  => "&nbsp;",
            "\t" => "&nbsp;&nbsp;&nbsp;",
            "\n" => "",
        },
        format_table => {
            Alert        => [ q{<span class="Alert">},           "</span>" ],
            BaseN        => [ q{<span class="BaseN">},           "</span>" ],
            BString      => [ q{<span class="BString">},         "</span>" ],
            Char         => [ q{<span class="Char">},            "</span>" ],
            Comment      => [ q{<span class="Comment"><i>},      "</i></span>" ],
            DataType     => [ q{<span class="DataType">},        "</span>" ],
            DecVal       => [ q{<span class="DecVal">},          "</span>" ],
            Error        => [ q{<span class="Error"><b><i>},     "</i></b></span>" ],
            Float        => [ q{<span class="Float">},           "</span>" ],
            Function     => [ q{<span class="Function">},        "</span>" ],
            IString      => [ q{<span class="IString">},         "" ],
            Keyword      => [ q{<b>},                            "</b>" ],
            Normal       => [ q{},                               "" ],
            Operator     => [ q{<span class="Operator">},        "</span>" ],
            Others       => [ q{<span class="Others">},          "</span>" ],
            RegionMarker => [ q{<span class="RegionMarker"><i>}, "</i></span>" ],
            Reserved     => [ q{<span class="Reserved"><b>},     "</b></span>" ],
            String       => [ q{<span class="String">},          "</span>" ],
            Variable     => [ q{<span class="Variable"><b>},     "</b></span>" ],
            Warning      => [ q{<span class="Warning"><b><i>},   "</b></i></span>" ],
        },
    );
}

=back

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered> and L<Syntax::Highlight::Engine::Kate>.

=head1 AUTHORS

Johannes Plunien L<plu@cpan.org|mailto:plu@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
