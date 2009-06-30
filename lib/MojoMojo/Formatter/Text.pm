package MojoMojo::Formatter::Text;

use base qw/MojoMojo::Formatter/;
use URI::Find;


=head1 NAME

MojoMojo::Formatter::Text - format plain text as xhtml

=head1 DESCRIPTION

This formatter will format content between {{txt}} and {{end}} as
 XHTML)

It is based on Angerwhale/Format/PlainText.pm

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Text formatter runs on 10

=cut

sub format_content_order { 10 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    my @lines = split /\n/, $$content;
    my $txt;
    $$content = "";
    my $start_re=$class->gen_re(qr/txt/);
    my $end_re=$class->gen_re(qr/end/);
    foreach my $line (@lines) {
        if ($txt) {
            if ( $line =~ m/^(.*)$end_re(.*)$/ ) {
                $$content .= MojoMojo::Formatter::Text->to_xhtml( $xhtml );
                $txt = "";
            }
            else { $txt .= $line . "\n"; }
        }
        else {
            if ( $line =~ m/^(.*)$start_re(.*)$/ ) {
                $$content .= $1;
                $txt = " ".$2;    # make it true :)
            }
            else { $$content .= $line . "\n"; }
        }
    }
}

=item to_xhtml <txt>

takes some text and renders it as XHTML.

=cut

sub to_xhtml {
    my ( $class, $text ) = @_;
    my $result;

    $text =~ s/&/&amp;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/'/&apos;/g;
    $text =~ s/"/&quot;/g;

    # find URIs
    my $finder = URI::Find->new(
                                sub {
                                    my($uri, $orig_uri) = @_;
                                    return qq|<a href="$uri">$orig_uri</a>|;
                                });
    $finder->find(\$text);

    # fix paragraphs
    my @paragraphs = split /\n+/m, $text;
    @paragraphs = grep { $_ !~ /^\s*$/ } @paragraphs;
    $result =  join( ' ', map { "<p>$_</p>" } @paragraphs );
    return qq{<div class="formatter_txt">\n$result</div>};
}


=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
