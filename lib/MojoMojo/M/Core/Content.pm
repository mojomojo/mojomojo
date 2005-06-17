package MojoMojo::M::Core::Content;

use strict;
use base 'Catalyst::Base';
use DateTime;
use DateTime::Format::Mail;
use utf8;

__PACKAGE__->has_a(
    created => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->has_a(
    remove_date => 'DateTime',
    inflate     => sub {
          DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->has_a(
    release_date => 'DateTime',
    inflate      => sub {
          DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->set_sql(max_ver=>'SELECT MAX(version) as max_ver  FROM __TABLE__ WHERE page=?');

__PACKAGE__->columns(TEMP=>qw/max_ver/);

__PACKAGE__->add_trigger( after_create => sub {$_[0]->created( DateTime->now ); $_[0]->update} );

sub highlight {
    my ( $self, $c ) = @_;
    my $this_content = $self->formatted($c);

    # FIXME: This may return undef. What do we do then?
    my $previous_content = (
        defined $self->previous
        ? $self->previous->formatted($c)
        : $this_content );
    my $this = [ split /\n/,                  $this_content ];
    my $prev = [ split /\n/,                  $previous_content ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    my $hi = 0;
    for my $line (@diff) {
        $hi++;
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<div id="hi$hi" class="fade">) . $$line[2] . "</div>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<div id="hi$hi"class="fade">) . $$line[2] . "</div>";
        } elsif ( $$line[0] eq "-" ) { }
        else { $diff .= $$line[1] }
    }
    return $diff;
}

sub formatted_diff {
    my ( $self, $c, $to ) = @_;
    my $this = [ split /\n/, $self->formatted($c) ];
    my $prev = [ split /\n/, $to->formatted($c) ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    for my $line (@diff) {
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<ins class="diffins">) . $$line[2] . "</ins>";
        }
        elsif ( $$line[0] eq "-" ) {
            $diff .= qq(<del class="diffdel">) . $$line[1] . "</del>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<del class="diffdel">) . $$line[1] . "</del>";
            $diff .= qq(<ins class="diffins">) . $$line[2] . "</ins>";
        }
        elsif ( $$line[0] eq "u" ) { $diff .= $$line[1] }
        else { $diff .= "Unknown operator " . $$line[0] }
    }
    return $diff;
}

sub formatted {
    my ( $self, $c, $content ) = @_;
    $content ||= $self->body_decoded;
    MojoMojo->call_plugins( "format_content", \$content, $c ) if ($content);
    return $content;
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
    eval { $page->isa('MojoMojo::M::Core::Page'); $page->content->isa('MojoMojo::M::Core::Content') };
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

sub max_version {
    my $self=shift;
    my $max=$self->search_max_ver($self->page);
    return 0 unless $max->count;
    return $max->next->max_ver();
}

sub body_decoded {
    my $self=shift;
    my $body=$self->body;
    utf8::decode($body);
    return $body;
}

sub pub_date {
    my $self=shift;
    return DateTime::Format::Mail->format_datetime($self->created);
}

# sub wikiwords {
#     my $self=shift;
#     my $content  = $self->content;
#     my @links;
#     while ( $content =~ m/
#     (?<![\?\\\/\[])(\b[A-Z][a-z]+[A-Z]\w*)/g) {
#       push @links, $1;
#     }
#     while ( $content =~ m{(?:\[\[|\(\()\s*([^\]\)|]+?)\s*(?:\|\s*([^\]\)]+?)\s*)?(?:\]\]|\)\))}g) {
#       push @links,MojoMojo->fixw( $1 );
#     }
#     return @links;
# }

1;
