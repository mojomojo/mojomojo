package MojoMojo::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

__PACKAGE__->config(
    dsn                => MojoMojo->config->{dsn},
    namespace          => 'MojoMojo::M',
    additional_classes => [
        qw/Class::DBI::AbstractSearch Class::DBI::Plugin::RetrieveAll
          Class::DBI::FromForm/
    ],
    relationships => 1
);

1;
