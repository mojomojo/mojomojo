package MojoMojo::V::TT;

use strict;
use base 'Catalyst::View::TT';
use Template::Constants qw( :debug );


#__PACKAGE__->config->{DEBUG}       = DEBUG_UNDEF;
__PACKAGE__->config->{PRE_CHOMP}   = 2;
__PACKAGE__->config->{POST_CHOMP}  = 2;

1;
