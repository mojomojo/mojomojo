package MojoMojo::Schema::ResultSet::Content;

use strict;
use warnings;
use parent qw/MojoMojo::Schema::Base::ResultSet/;

=head1 NAME

MojoMojo::Schema::ResultSet::Content - resultset methods on content

=head1 METHODS

=head2 format_content

    $formatted_content = format_content($c, $content, $page);

Call all available formatters to format content, according to their
format_content_order.

=cut

sub format_content {

    # FIXME: This thing should use accept-context and stop fucking around with $c everywhere
    my ( $self, $c, $content, $page ) = @_;
    MojoMojo->call_plugins( "format_content", \$content, $c, $page )
        if ($content);
    return $content;
}

=head2 create_proto <page>

Create a content prototype hash, as the basis for a new revision.

=cut

sub create_proto {
    my ( $class, $page ) = @_;
    my %proto_content;
    my @columns = $class->result_source->columns;
    eval {
        $page->isa('MojoMojo::Schema::Page');
        $page->content->isa('MojoMojo::Schema::Content');
    };
    if ($@) {

        # assume page is a simple "proto page" hashref,
        # or the page has no content yet
        %proto_content = map { $_ => undef } @columns;
        $proto_content{version} = 1;
    }
    else {
        my $content = $page->content;
        %proto_content = map { $_ => $content->$_ } @columns;
        @proto_content{qw/ creator created comments /} = (undef) x 3;
        $proto_content{version}++;
    }
    return \%proto_content;
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
