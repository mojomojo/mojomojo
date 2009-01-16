package MojoMojo::Controller::Out;

use strict;
use base 'Catalyst::Controller';
use YAML;
=head1 NAME


=head1 DESCRIPTION


=head1 METHODS

=cut


=head2 index 

=cut

sub default : Global {
    my ($self, $c, $go, $id ) = @_;
    $c->config( YAML::LoadFile($c->config->{'affiliate'}));
    if ($id &&  $c->config->{$id} ) {
    $c->stash->{good_url} = $c->config->{$id};
    $c->stash->{template} = 'out.tt';
    }
    else {
        $c->forward('page_not_found');
    }

}

sub page_not_found : Private {
    my ( $self, $c )      = @_;
	$c->res->status('404');
    $c->stash->{template}='error/error404.tt';
}

=head1 AUTHOR

Pierrick DINTRAT

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
