package MojoMojo::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

use Catalyst::Model::CDBI::Sweet;

die "No DSN defined" unless MojoMojo->config->{dsn};
__PACKAGE__->config(
    dsn                => MojoMojo->config->{dsn},
    namespace          => 'MojoMojo::M::Core',
    additional_classes => [
        qw/Class::DBI::FromForm Class::DBI::Sweet::Topping/
    ],
    relationships => 1
);

sub new {
     my $class = shift;
     my $self = $class->NEXT::new(@_);
     foreach my $subclass ( $self->loader->classes ) {
         no strict 'refs';
         unshift @{ $subclass . '::ISA' }, 'Catalyst::Model::CDBI::Sweet';
     }
     return $self;
}

1;
