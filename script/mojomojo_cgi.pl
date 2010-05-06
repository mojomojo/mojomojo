#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_ENGINE} ||= 'CGI' }

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo;

MojoMojo->run;

1;

=head1 NAME

mojomojo_cgi.pl - Catalyst CGI

=head1 SYNOPSIS

See L<Catalyst::Manual>

=head1 DESCRIPTION

Run a Catalyst application as a cgi script.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=head1 COPYRIGHT

Please refer to Catalyst.pm for copyright details.


=cut
