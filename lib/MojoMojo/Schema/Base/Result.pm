package MojoMojo::Schema::Base::Result;

use strict;
use warnings;
use parent qw/DBIx::Class/;

=head1 NAME

MojoMojo::Schema::Base::Result - base class for Result classes

=head1 DESCRIPTION

Base class for all result classes below the MojoMojo::Schema::Result::* namespace.

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 Methods

=head2 sqlt_deploy_hook

Set Database specific info to achieve UTF-8 support in the database we deploy to.

=cut

sub sqlt_deploy_hook {
    my ( $self, $sqlt_table ) = @_;
    $sqlt_table->extra(
        mysql_table_type => 'InnoDB',
        mysql_charset    => 'utf8'
    );
}

1;
