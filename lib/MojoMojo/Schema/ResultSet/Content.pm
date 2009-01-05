package MojoMojo::Schema::ResultSet::Content;

use strict;
use warnings;
use base qw/MojoMojo::Schema::Base::ResultSet/;

=head1 NAME

MojoMojo::Schema::ResultSet::Content

=head1 METHODS

=over 4

=item format_content

Uses all available formatters of MojoMojo to format content.

=cut

sub format_content {

    # FIXME: This thing should use accept-context and stop fucking around with $c everywhere
    my ( $self, $c, $content, $page ) = @_;
    $c ||= MojoMojo->instance();
    MojoMojo->call_plugins( "format_content", \$content, $c, $page )
        if ($content);
    return $content;
}

# create_proto: create a "proto content version" that may
# be the basis for a new revision

=item create_proto <page>

Create a content prototype object, as the basis for a new revision.

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

1;