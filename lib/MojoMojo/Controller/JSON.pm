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

=item tag search (json/tagsearch)

Backend which handles jQuery autocomplete requests for tag.

=cut

sub tagsearch : Local {
    my ($self, $c) = @_;
    my $query = $c->req->param('q');

    #$c->stash->{template} = "user/user_search.tt";
    
    $c->log->debug('Just before if');
    if (defined($query) && length($query)) {
        my $rs = $c->model('DBIC::Tag')->search_like({
            tag => '%'.$query.'%'
        });
        $c->stash->{users} = 'ok something here';
    }
    undef $c->stash->{page};
    $c->log->debug('Just before forwarding');
}

sub auto : Private {
    my ($self,$c) =@_;
   $c->stash->{current_view}='MojoMojo::View::JSON';
   return 1;
}

1;

=head1 AUTHOR

Sachin Sebastian <sachinjsk at cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

