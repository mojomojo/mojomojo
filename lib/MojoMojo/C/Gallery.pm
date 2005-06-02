package MojoMojo::C::Gallery;

use strict;
use base 'Catalyst::Base';
use Carp qw/verbose/;

=head1 NAME

MojoMojo::C::Gallery - Catalyst component

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c, $action, $page) = @_;
    $c->stash->{template} = 'gallery.tt';
    #my ($pager);
    #my $iterator = MojoMojo::M::Core::Attachment->search(
    # oops, we have a column value named Page
    $c->log->debug('page is '.$page);
    my ($pager,$iterator) =MojoMojo::M::Core::Attachment->pager( 
             {contenttype=>  {-like=>'image/%'},
             page=>$c->stash->{page}->id},
             { page =>$page || 1,
              rows => 18,
            });
    $c->stash->{pictures} = $iterator;
    $c->stash->{pager} = $pager;
}

sub p : Global {
    my ( $self, $c, $photo ) = @_;
    $c->stash->{template}='gallery/photo.tt';
    $c->stash->{photo}= MojoMojo::M::Core::Attachment->retrieve($photo);
}
=back


=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
