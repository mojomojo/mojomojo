package MojoMojo::I18N;
use strict;

use parent 'Locale::Maketext';

*loc = \&localize;

sub localize {
    my $self = shift;

    return $self->maketext(@_);
}

1;
