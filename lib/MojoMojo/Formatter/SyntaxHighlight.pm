package MojoMojo::Formatter::SyntaxHighlight;

use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;
use HTML::Entities;

eval {require Syntax::Highlight::Engine::Kate};
my $kate_installed = !$@;

=head2 module_loaded

Return true if the module is loaded.

=cut

sub module_loaded { $kate_installed }

my $main_formatter;
eval { $main_formatter = MojoMojo->pref('main_formatter'); };
$main_formatter ||= 'MojoMojo::Formatter::Markdown';

=head1 NAME

MojoMojo::Formatter::SyntaxHighlight - syntax highlighting for code blocks

=head1 DESCRIPTION

This formatter performs syntax highlighting on code blocks.

=head1 METHODS

=head2 format_content_order

The syntax highlight formatter is based on C<< <pre> >> tags entered by the
user, so it must run before other formatters that produce C<< <pre> >> tags.
The earliest such formatter is the main formatter.

=cut

sub format_content_order { 14 }

=head2 format_content

This formatter uses L<Syntax::Highlight::Engine::Kate> to syntax highlight code
inside of C<< <pre lang="language"> ... </pre> >> tags:

 <pre lang="Perl">
   say "Hello world!";
 </pre>

See L<Syntax::Highlight::Engine::Kate/PLUGINS> for a list of supported
languages.

=cut

# The $kate formatter is scoped outside of format_content. Otherwise, memory
# leaks have occurred. This is also faster, as it avoids instantiation for every
# request.
my $kate;

sub format_content {
    my ( $class, $content ) = @_;
    return unless $class->module_loaded;

    my @blocks  = ();
    my $ph      = 0;
    my $ph_base = __PACKAGE__ . '::PlaceHolder::';

# new school - consistent with other new syntax, but broke for me to the point of exhaustion
# $$content =~ s/\{\{\s*code\s+lang=""\s*\}\}/<pre>/g;
# while ( $$content =~ s/\{\{\s*code(?:\s+lang=['"]*(.*?)['"]*")?\s*\}\}(.*?)\{\{\s*end\s*\}\}/$ph_base$ph/si ) {
# drop all lang="" -- mateu
    $$content =~ s/<\s*pre\s+lang=""\s*>/<pre>/g;
    while ( $$content =~ s/<\s*pre(?:\s+lang=['"]*(.*?)['"]*")?\s*>(.*?)<\s*\/pre\s*>/$ph_base$ph/si ) {
        my ( $language, $block ) = ( $1, $2 );

        # Fix newline issue
        $block =~ s/\r//g;

        if ($language) {
            eval {
                $kate->language($language);
            } and do {
                $block = $kate->highlightText($block);
            }
        }
        push @blocks, $block;
        $ph++;
    }

    for ( my $i = 0 ; $i < $ph ; $i++ ) {
        $$content =~ s/$ph_base$i/<pre>$blocks[$i]<\/pre>/;
    }

    return $content;
}

if (module_loaded) {
    $kate = Syntax::Highlight::Engine::Kate->new(
        language      => 'Perl',
        substitutions => {
            "<" => "&lt;",
            ">" => "&gt;",
            "&" => "&amp;",
            "^" => "&circ;",
            " "  => "&nbsp;",
            "\t" => "&nbsp;&nbsp;&nbsp;&nbsp;",
            "\n" => "\n",
        },
        format_table => {
            Alert    => [ q{<span class="kateAlert">},      "</span>" ],
            BaseN    => [ q{<span class="kateBaseN">},      "</span>" ],
            BString  => [ q{<span class="kateBString">},    "</span>" ],
            Char     => [ q{<span class="kateChar">},       "</span>" ],
            Comment  => [ q{<span class="kateComment"><i>}, "</i></span>" ],
            DataType => [ q{<span class="kateDataType">},   "</span>" ],
            DecVal   => [ q{<span class="kateDecVal">},     "</span>" ],
            Error    => [ q{<span class="kateError"><b><i>}, "</i></b></span>" ],
            Float    => [ q{<span class="kateFloat">},       "</span>" ],
            Function => [ q{<span class="kateFunction">}, "</span>" ],
            IString  => [ q{<span class="kateIString">},  "" ],
            Keyword  => [ q{<b>},                         "</b>" ],
            Normal   => [ q{},                            "" ],
            Operator => [ q{<span class="kateOperator">}, "</span>" ],
            Others   => [ q{<span class="kateOthers">},   "</span>" ],
            RegionMarker => [ q{<span class="kateRegionMarker"><i>}, "</i></span>" ],
            Reserved => [ q{<span class="kateReserved"><b>}, "</b></span>" ],
            String   => [ q{<span class="kateString">},      "</span>" ],
            Variable => [ q{<span class="kateVariable"><b>}, "</b></span>" ],
            Warning  => [ q{<span class="kateWarning"><b><i>}, "</b></i></span>" ],
        },
    );
}    

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered> and L<Syntax::Highlight::Engine::Kate>.

=head1 AUTHORS

Johannes Plunien E<lt>plu@cpan.orgE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
