package MojoMojo::View::TT;

use strict;
use parent 'Catalyst::View::TT';
use Template::Constants qw( :debug );
use Class::C3 ();

=head1 MojoMojo::V::TT - Template Toolkit views for MojoMojo

=head1 SYNOPSIS

  # in some action
  $c->forward('MojoMojo::V::TT');

=head1 DESCRIPTION

Subclass of L<Catalyst::View::TT>.

=cut


#__PACKAGE__->config->{DEBUG}       = DEBUG_UNDEF;
__PACKAGE__->config->{PRE_CHOMP}          = 2;
__PACKAGE__->config->{POST_CHOMP}         = 2;
__PACKAGE__->config->{CONTEXT}            = undef;
__PACKAGE__->config->{TEMPLATE_EXTENSION} = '.tt';
__PACKAGE__->config->{PRE_PROCESS}        = 'global.tt';
__PACKAGE__->config->{FILTERS}            = { nav => [ \&_nav_filter, 1 ] };

sub new {
    my $class  = shift;

    my ( $c, $arg_ref ) = @_;

    $class->config->{INCLUDE_PATH}=[
        $c->path_to('root'),
        $c->path_to('root','base'),
    ];

    return $class->next::method(@_);
}

=head2 _nav_filter

Add a "navOn" class to all HTML links that point to the current request URI.
Use by navbar TT code.

=cut

sub _nav_filter {
    my ( $context, @args ) = @_;

    my $c = $context->stash()->{c};

    return sub {
        my $html = shift;

        my $uri = $c->req->uri;

        $html =~ s{<a([^>]+)(href="\Q$uri\E")}{<a class="navOn" $1$2};

        return $html;
    };
}

=head1 SEE ALSO

L<Catalyst::View::TT>

=head1 AUTHORS

Marcus Ramberg C<marcus@thefeed.no>
David Naughton C<naughton@umn.edu>
Dave Rolsky C<autarch@urth.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
