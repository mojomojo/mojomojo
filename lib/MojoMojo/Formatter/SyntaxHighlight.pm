package MojoMojo::Formatter::SyntaxHighlight;

use strict;
use warnings;
use base qw/MojoMojo::Formatter/;
use HTML::Entities;

eval "use Syntax::Highlight::Engine::Kate;";
my $eval_res=$@;

sub module_loaded { $eval_res ? 0 : 1 }


my $main_formatter;
eval {
    $main_formatter = MojoMojo->pref('main_formatter');
};
$main_formatter ||= 'MojoMojo::Formatter::Markdown';

=head1 NAME

MojoMojo::Formatter::SyntaxHighlight - syntax highlighting for code blocks

=head1 DESCRIPTION

This formatter performs syntax highlighting on code blocks.

=head1 METHODS

=over 4

=item format_content_order

The syntax highlight formatter is based on E<lt>preE<gt> tags and
therefore it's elementary to get those unchanged. So we need to run
this plugin before L<MojoMojo::Formatter::Wiki> which actually changes
those tags.

=cut

sub format_content_order { 99 }

=item format_content

This formatter uses L<Syntax::Highlight::Engine::Kate> to highlight code
syntax inside of <pre lang="my_lang"> </pre>tags. To let the formatter know which language
has to be highlighted, do:

 <pre lang="Perl">
   say "Hola Mundo";
 </pre> 

See L<Syntax::Highlight::Engine::Kate/PLUGINS> for a list of supported
languages.

=cut

# NOTE: Moved $kate outside of format_content method because
# of apparent memory links so we want to re-use the object instead
# of creating a new one each time a page is requested.
my $kate = _kate();

sub format_content {
    my ( $class, $content ) = @_;
    return unless $class->module_loaded;

    my @blocks  = ();
    my $ph      = 0;
    my $ph_base = __PACKAGE__ . '::PlaceHolder::';

    # new school - consistent with other new syntax, but broke for me to the point of exhaustion
    # $$content =~ s/\{\{\s*code\s+lang=""\s*\}\}/<pre>/g;
    # while ( $$content =~ s/\{\{\s*code(?:\s+lang=['"]*(.*?)['"]*")?\s*\}\}(.*?)\{\{\s*end\s*\}\}/$ph_base$ph/si ) {
    # old school - which works with textile2 (not textile for mxh)
    # drop all lang=""
    $$content =~ s/<\s*pre\s+lang=""\s*>/<pre>/g;
    while ( $$content =~ s/<\s*pre(?:\s+lang=['"]*(.*?)['"]*")?\s*>(.*?)<\s*\/pre\s*>/$ph_base$ph/si ) {
        my ($language, $block) = ($1, $2);
        # Fix newline issue
        $block =~ s/\r//g;

        # Unfortunately markdown also encodes entities at some level which is not possible to disable
        # neither easy to hack like we do for textile. So let's decode &amp; to & to avoid:
        # &gt; => &amp;gt;
        $block =~ s/&amp;/&/g;

        $block = decode_entities($block);
        if ($language) {
            eval {
                $kate->language($language);
            };
            unless ($@) {
                $block = $kate->highlightText($block);
            }
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
            " "  => "&nbsp;",
            "\t" => "&nbsp;&nbsp;&nbsp;",
            "\n" => "\n",
        },
        format_table => {
            Alert        => [ q{<span class="kateAlert">},           "</span>" ],
            BaseN        => [ q{<span class="kateBaseN">},           "</span>" ],
            BString      => [ q{<span class="kateBString">},         "</span>" ],
            Char         => [ q{<span class="kateChar">},            "</span>" ],
            Comment      => [ q{<span class="kateComment"><i>},      "</i></span>" ],
            DataType     => [ q{<span class="kateDataType">},        "</span>" ],
            DecVal       => [ q{<span class="kateDecVal">},          "</span>" ],
            Error        => [ q{<span class="kateError"><b><i>},     "</i></b></span>" ],
            Float        => [ q{<span class="kateFloat">},           "</span>" ],
            Function     => [ q{<span class="kateFunction">},        "</span>" ],
            IString      => [ q{<span class="kateIString">},         "" ],
            Keyword      => [ q{<b>},                            "</b>" ],
            Normal       => [ q{},                               "" ],
            Operator     => [ q{<span class="kateOperator">},        "</span>" ],
            Others       => [ q{<span class="kateOthers">},          "</span>" ],
            RegionMarker => [ q{<span class="kateRegionMarker"><i>}, "</i></span>" ],
            Reserved     => [ q{<span class="kateReserved"><b>},     "</b></span>" ],
            String       => [ q{<span class="kateString">},          "</span>" ],
            Variable     => [ q{<span class="kateVariable"><b>},     "</b></span>" ],
            Warning      => [ q{<span class="kateWarning"><b><i>},   "</b></i></span>" ],
        },
    );
}

=back

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered> and L<Syntax::Highlight::Engine::Kate>.

=head1 AUTHORS

Johannes Plunien E<lt>plu@cpan.orgE<gt>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
