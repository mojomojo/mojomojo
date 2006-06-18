package MojoMojo::M::Core::PageVersion;

use strict;
use base 'Catalyst::Base';
use utf8;
use DateTime;

#FIXME: Need better docs

=head1 NAME

MojoMojo::M::Core::PageVersion - Represents page versions


=head1 DESCRIPTION

Represents page versions

=over 4
=cut

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

MojoMojo::M::Core::PageVersion->has_a( 'creator' => 'MojoMojo::M::Core::Person' );

__PACKAGE__->add_trigger( after_create => sub {$_[0]->created( DateTime->now ); $_[0]->update} );


=item formatted_diff

Alias to L<MojoMojo::M::Core::Page>'s formatted_diff method.

=cut

# this should probably be re-defined here...
sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}


=back

=head1 AUTHORS

David Naughton <naughton@umn.edu>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
