package MojoMojo::M::Core::PageVersion;

use strict;
use base 'Catalyst::Base';
use DateTime;
use utf8;

__PACKAGE__->has_a(
    remove_date => 'DateTime',
    inflate     => sub {
          DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->has_a(
    release_date => 'DateTime',
    inflate      => sub {
          DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->has_a(
    created => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->add_trigger( after_create => sub {$_[0]->created( DateTime->now ); $_[0]->update} );

# this should probably be re-defined here...
sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

1;
