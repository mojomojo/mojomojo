package Text::Wikispaces2Markdown;
use strict;
our $VERSION = "0.1";

=head1 NAME

B<Wikispaces2Markdown>

=head1 SYNOPSIS

Do a rough conversion of Wikispaces.com markup into Markdown.

=head1 METHODS

=over 4

=item convert

Does the conversion using dumb regexp rules. Would fare better with a proper parser.

=cut

sub convert {
    shift if ( $_[0] eq __PACKAGE__ );    # oops, called in OOP fashion.

    # Paramaters:
    my $text = shift;                     # text to be parsed

    my @lines = split /\n/, $text;

    for my $i (0..$#lines) {
        $_ = $lines[$i];
        # convert links
        $lines[$i] =~ s/\[\[(.*?)\|(.*?)]]/[$2]($1)/g;
        # convert italic
        $lines[$i] =~ s{(?<!:)//}{_}g;  # FIXME: very crude avoidance of URLs; will break in code blocks
        # convert ToC
        $lines[$i] =~ s/\Q[[toc]]/{{toc}}/g;
        # convert nested lists
        $lines[$i] =~ s/^([#*])\1+/('  ' x length $&) . $1/meg;

        # convert ordered lists
        $lines[$i] =~ s/^(\s*)#/$1 . '1.'/meg;
        # add a line before lists, as (annoyingly) required by Markdown
        if ($lines[$i] =~ /^[*0-9]/ and $i > 0 and $lines[$i-1] !~ /^\s*$|^\s*[*0-9]/) {
            substr($lines[$i], 0, 0, "\n");
        }
        # convert headings
        if ($lines[$i] =~ s/^(=+)(.+?)=*$/('#' x length $1) . ' ' . $2/me) {
            # make sure headings are preceded by a blank line
            substr($lines[$i], 0, 0, "\n") if $i > 0 and $lines[$i-1] !~ /^\s*$/;
            # remove explicit anchors to headings (e.g. '=[[#Reliability]] Reliability='; assumes you run a {{toc}})
            # $lines[$i] =~ s/\[\[#(.*?)]] \1/[[$1]]/;
            # remove anchors anwyay - they seem to be an odd artefact of Wikispaces. Be careful in the strange case in which anchors are named something other than the heading's 'a' name
            $lines[$i] =~ s/\[\[#(.*?)]] (.*)/$2/;
        }



    }

    return (join "\n", @lines) . ($text =~ /(\n+)\z/? $1 : '');  # append the last \n if any, which would be lost by the initial split
}

=back

=head1 AUTHORS

Author: Dan Dascalescu (dandv), L<http://dandascalescu.com>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut


1;
