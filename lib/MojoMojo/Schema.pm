package MojoMojo::Schema;

use strict;
use warnings;

use Moose;

has 'attachment_dir' => (is=>'rw', isa=>'Str');

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;

1;
