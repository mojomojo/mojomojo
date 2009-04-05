#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";


use MojoMojo::Formatter::DocBook;
use File::Slurp;

my $content = read_file( shift ) ;

print MojoMojo::Formatter::DocBook->to_xhtml( $content );


__END__

=head1 Usage

dbk2xhtml.pl docbookfile

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This script is licensed under the same terms as Perl itself.

=cut
