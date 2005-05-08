package MojoMojo::M::Core::Content;

use strict;
use base 'Catalyst::Base';
use Time::Piece;
use utf8;

__PACKAGE__->add_trigger(
    after_set_content => sub {
        my $self = shift;
        $self->created( localtime->datetime );
        $self->update();
    }
);
__PACKAGE__->has_a(
    created => 'Time::Piece',
    inflate => sub {
        Time::Piece->strptime( shift, "%FT%H:%M:%S" );
    },
    deflate => 'datetime'
);

# this is in Page.pm now, but maybe should go here...?
sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

sub formatted {
    my ( $self, $base, $content ) = @_;
    $content ||= $self->utf8;
    MojoMojo->call_plugins( "format_content", \$content, $base ) if ($content);
    return $content;
}

sub utf8 {
    my $self = shift;
    my $body = $self->body;
    utf8::decode($body);
    return $body;
}

sub previous {
    my ($self) = @_;
    return (
        $self->version > 1
        ? __PACKAGE__->retrieve(
            page    => $self->page,
            version => $self->version - 1
          )
        : undef
    );
}

# create_proto: create a "proto content version" that may
# be the basis for a new revision

sub create_proto {
    my ( $class, $page ) = @_;
    my %proto_content;
    my @columns = __PACKAGE__->columns;
    eval { $page->isa('MojoMojo::M::Core::Page') };
    if ($@) {

        # assume page is a simple "proto page" hashref
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
