package Locale::Maketext::Extract::Plugin::FormFu;

use strict;
use base qw(Locale::Maketext::Extract::Plugin::Base);

=head1 NAME

Locale::Maketext::Extract::Plugin::FormFu - FormFu format parser

=head1 SYNOPSIS

    $plugin = Locale::Maketext::Extract::Plugin::FormFu->new(
        $lexicon            # A Locale::Maketext::Extract object
        @file_types         # Optionally specify a list of recognised file types
    )

    $plugin->extract($filename,$filecontents);

=head1 DESCRIPTION

HTML::FormFu uses a config-file to generate forms, with built in support
for localizing errors, labels etc.

=head1 SHORT PLUGIN NAME

    formfu

=head1 VALID FORMATS

We extract the text after _loc:

    content_loc: this is the string

=head1 KNOWN FILE TYPES

=over 4

=item All file types

=back

=cut

sub file_types {
    return qw( * );
}

sub extract {
    my $self = shift;
    my $content = shift;
    my $lno = 0;
    foreach my $line (split /\n/, $content) {
        $lno++;
        if (my ($str) = $line =~ /.*?_loc[:]*\s+['"]*(.*?)['"]*$/) {
            $self->add_entry($str, $lno);
        }
    }
}

=head1 SEE ALSO

=over 4

=item L<xgettext.pl>

for extracting translatable strings from common template
systems and perl source files.

=item L<Locale::Maketext::Lexicon>

=item L<Locale::Maketext::Plugin::Base>

=item L<Locale::Maketext::Plugin::Perl>

=item L<Locale::Maketext::Plugin::TT2>

=item L<Locale::Maketext::Plugin::YAML>

=item L<Locale::Maketext::Plugin::Mason>

=item L<Locale::Maketext::Plugin::TextTemplate>

=item L<Locale::Maketext::Plugin::Generic>

=back

=head1 AUTHORS

Audrey Tang E<lt>cpan@audreyt.orgE<gt>

=head1 COPYRIGHT

Copyright 2002-2008 by Audrey Tang E<lt>cpan@audreyt.orgE<gt>.

This software is released under the MIT license cited below.

=head2 The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

=cut


1;
