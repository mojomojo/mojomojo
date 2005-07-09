package MojoMojo::M::Core::Content;

use strict;
use base 'Catalyst::Base';
use DateTime;
use DateTime::Format::Mail;
use utf8;

=head1 NAME

MojoMojo::M::Core::Content - Page content

=head1 DESCRIPTION

This class represents the actual content of a page, one row for
each version.

=head1 METHODS 

=over 4

=cut

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
MojoMojo::M::Core::Content->has_a( 'creator' => 'MojoMojo::M::Core::Person' );
MojoMojo::M::Core::Content->has_a( 'page' => 'MojoMojo::M::Core::Page' );


__PACKAGE__->set_sql(max_ver=>'SELECT MAX(version) as max_ver  FROM __TABLE__ WHERE page=?');

__PACKAGE__->columns(TEMP=>qw/max_ver/);

__PACKAGE__->add_trigger( after_create => sub {$_[0]->created( DateTime->now ); $_[0]->update} );

__PACKAGE__->add_trigger( after_create     => \&store_links );
__PACKAGE__->add_trigger( after_update     => \&store_links );
__PACKAGE__->add_trigger( after_set_status => \&store_links );

=item highlight

Highlight new lines in content compared to previous version
using yellow fade.

=cut

sub highlight {
    my ( $self, $c ) = @_;
    my $this_content = $self->formatted($c);

    # FIXME: This may return undef. What do we do then?
    my $previous_content = (
        defined $self->previous
        ? $self->previous->formatted($c)
        : $this_content );
    my $this = [ split /\n\n/,                  $this_content ];
    my $prev = [ split /\n\n/,                  $previous_content ];
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

=item formatted_diff <context> <old_content>

Compare this content version to <old_content>, using
Algorithm::Diff. Show added lines in with diffins css class
and deleted with diffdel css class.

=cut

sub formatted_diff {
    my ( $self, $c, $to ) = @_;
    my $this = [ split /\n\n/, $self->formatted($c) ];
    my $prev = [ split /\n\n/, $to->formatted($c) ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    for my $line (@diff) {
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<div class="diffins">) . $$line[2] . "</div>";
        }
        elsif ( $$line[0] eq "-" ) {
            $diff .= qq(<div class="diffdel">) . $$line[1] . "</div>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<div class="diffdel">) . $$line[1] . "</div>";
            $diff .= qq(<div class="diffins">) . $$line[2] . "</div>";
        }
        elsif ( $$line[0] eq "u" ) { $diff .= $$line[1] }
        else { $diff .= "Unknown operator " . $$line[0] }
    }
    return $diff;
}

=item formatted [<content>]

Return content after being run through MojoMojo::Formatter::* , 
either own content or passed <content>

=cut

sub formatted {
    my ( $self, $c, $content ) = @_;
    $content ||= $self->body_decoded;
    MojoMojo->call_plugins( "format_content", \$content, $c ) if ($content);
    return $content;
}

=item previous

Return previous version of this content, or undef for first version.

=cut

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

=item create_proto <page>

Create a content prototype object, as the basis for a new revision.

=cut

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

=item max_version 

Return the highest numbered revision.

=cut

sub max_version {
    my $self=shift;
    my $max=$self->search_max_ver($self->page);
    return 0 unless $max->count;
    return $max->next->max_ver();
}

=item body_decoded

Return content marked as utf8.

=cut

sub body_decoded {
    my $self=shift;
    my $body=$self->body;
    utf8::decode($body);
    return $body;
}

=item  pub_date

return publish date of this version in a format suitable for RSS 2.0

=cut

sub pub_date {
    my $self=shift;
    return DateTime::Format::Mail->format_datetime($self->created);
}

=item store_links

Extract and store all links and wanted paged from a given content
version.

=cut

sub store_links {
    my ($self) = @_;
    return unless ($self->status eq 'released');
    my $content = $self->body_decoded;
    my $page = $self->page;
    require MojoMojo::Formatter::Wiki;
    my ($linked_pages, $wanted_pages) = MojoMojo::Formatter::Wiki->find_links( \$content, $page );
    return unless (@$linked_pages || @$wanted_pages);
    MojoMojo::M::Core::Link->search( from_page => $page )->delete_all;
    MojoMojo::M::Core::WantedPage->search( from_page => $page )->delete_all;
    for (@$linked_pages) {
        my $link = MojoMojo::M::Core::Link->find_or_create({ from_page => $self->page, to_page => $_->id });
    }
    for (@$wanted_pages) {
        my $wanted_page = MojoMojo::M::Core::WantedPage->find_or_create({ from_page => $page, to_path => $_->{path} });
    }
}

=back

=head1 SEE ALSO

L<Class::DBI::Sweet>, L<Catalyst>, L<MojoMojo>

=head1 AUTHORS

David Naughton C<naughton@umn.edu>
Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
