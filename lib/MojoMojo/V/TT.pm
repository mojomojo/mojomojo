package MojoMojo::V::TT;

use strict;
use base 'Catalyst::View::TT';
__PACKAGE__->config->{DEBUG}       = 'all';
__PACKAGE__->config->{PRE_CHOMP}   = 2;
__PACKAGE__->config->{POST_CHOMP}  = 2;

1;
