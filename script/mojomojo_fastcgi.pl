#!/usr/bin/perl -w

BEGIN { $ENV{CATALYST_ENGINE} ||= 'FastCGI' }

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo;

MojoMojo->run;

1;

=head1 NAME

mojomojo_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

See L<Catalyst::Manual>

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut
