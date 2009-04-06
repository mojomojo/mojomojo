package MojoMojo::Controller::JSON;

use strict;
use base 'Catalyst::Controller';

=head1 NAME

MojoMojo::Controller::JSON - Various functions that return JSON data.

=head1 SYNOPSIS

This is the Mojo for various functions that return json data.

=head1 DESCRIPTION

This controller dispatches various json data to ajax methods in mojomojo
These methods will be called indirectly through javascript functions.

=head1 ACTIONS

=over 4

=item tagsearch (json/tagsearch)

Backend which handles jQuery autocomplete requests for tag.

=back

=cut

sub tagsearch : Local {
   my ($self, $c) = @_;
   my $query = $c->req->param('q');

   if (defined($query) && length($query)) {
       my $rs = $c->model('DBIC::Tag')->search_like({
           tag => $query.'%'
       }, {
           select => [ { distinct => [ 'tag' ] } ],
           as => [ 'tag' ]
       });

       my @tags;
       while( my $each_rs = $rs->next )
       {
           push(@tags, $each_rs->tag);
       }
       $c->stash->{json}->{tags} = \@tags;
   }
}

=over 4

=item container_set_default_width (json/container_set_default_width)

Store width in session variable I<container_default_width>

=back

=cut

sub container_set_default_width : Local {
   my ($self, $c, $width) = @_;
   $c->session->{container_default_width}=$width;
   $c->stash->{json}->{width}=$width;
}


=over 4

=item container_maximize_width (json/container_maximize_width)

Set or unset session variable I<maximize_width>, which is used to maximize
width 

=back

=cut
sub container_maximize_width : Local {
   my ($self, $c, $width) = @_;
   if ($width){
     $c->session->{maximize_width}=1;
   } else {
     delete ($c->session->{maximize_width});
   }
   $c->stash->{json}->{width}=$c->session->{container_set_default_width};
}


=head2 auto

Set default view

=cut

sub auto : Private {
   my ($self, $c) = @_;

   $c->stash->{current_view} = 'JSON';
   return 1;
}

1;

=head1 AUTHOR

Sachin Sebastian <sachinjsk at cpan.org>

Robert Litwiniec <linio at wonder.pl>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

