package MojoMojo::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

die "No DSN defined" unless MojoMojo->config->{dsn};
__PACKAGE__->config(
    dsn                => MojoMojo->config->{dsn},
    namespace          => 'MojoMojo::M::Core',
		debug							 => 1,
    additional_classes => [
        qw/Class::DBI::AbstractSearch Class::DBI::Plugin::RetrieveAll
          Class::DBI::FromForm/
    ],
    relationships => 1
);

1;
