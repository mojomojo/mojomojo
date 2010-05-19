package MojoMojo::I18N;
use strict;

use parent 'Locale::Maketext';

=head1 Methods

=head2 loc

Abbreviation for localize()

=cut

*loc = \&localize;

=head2 localize

Translate text to locality

=cut

sub localize {
    my $self = shift;

    return $self->maketext(@_);
}

=head2 tense

This is only here to satisfy Pod coverage tests.  
Not sure why t/03podcoverage.t thinks there is a tense sub in here?

=head1 NAME

MojoMojo::I18N - support for language localization

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
