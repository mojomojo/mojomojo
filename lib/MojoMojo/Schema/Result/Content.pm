package MojoMojo::Schema::Result::Content;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

=head1 NAME

MojoMojo::Schema::Result::Content - Versioned page content

=head1 DESCRIPTION

This table stores the actual page content; in other words, it's a table of
page versions (revisions). It has a composite primary key C<(page, version)>,
where C<page> is the id of a page, and C<version> is its version number. Each
version has a content C<body>, a C<status> ("released" or "removed"), and a
C<release_date>. Revisions that have been replaced by a newer revision have a
C<remove_date> and a C<comments> set to "Replaced by version x.".

The C<type>, C<abstract> and C<precompiled> columns are for future use.

C<created> is essentially equal to C<release_date> (there can be a 1-second
difference), and is used externally by other modules and in templates.
C<release_date> and C<remove_date> are used internally.

=cut

use DateTime::Format::Mail;

use Algorithm::Diff;
use Algorithm::Merge qw/merge/;
use String::Diff;
use HTML::Entities qw/encode_entities_numeric/;

__PACKAGE__->load_components(
    qw/DateTime::Epoch TimeStamp UTF8Columns Core/);
__PACKAGE__->table("content");
__PACKAGE__->add_columns(
    "page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "version",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "creator",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "created",
    {
        data_type        => "BIGINT",
        is_nullable      => 0,
        size             => 100,
        inflate_datetime => 'epoch',
        set_on_create    => 1,
    },
    "status",
    { data_type => "VARCHAR", is_nullable => 0, size => 20 },
    "release_date",
    {
        data_type                 => "BIGINT",
        is_nullable               => 0,
        size                      => 100,
        default_value             => undef,
        inflate_datetime          => 'epoch',
        datetime_undef_if_invalid => 1,
    },
    "remove_date",
    {
        data_type                 => "BIGINT",
        is_nullable               => 1,
        size                      => 100,
        default_value             => undef,
        inflate_datetime          => 'epoch',
        datetime_undef_if_invalid => 1,
    },
    "type",
    { data_type => "VARCHAR", is_nullable => 1, size => 200 },
    "abstract",
    { data_type => "TEXT", is_nullable => 1, size => 4000 },
    "comments",
    { data_type => "TEXT", is_nullable => 1, size => 4000 },
    "body",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "precompiled",
    { data_type => "TEXT", is_nullable => 1, size => undef },

);
__PACKAGE__->utf8_columns(qw/abstract body precompiled/);
__PACKAGE__->set_primary_key( "version", "page" );
__PACKAGE__->has_many(
    "pages",
    "MojoMojo::Schema::Result::Page",
    {
        "foreign.content_version" => "self.version",
        "foreign.id"              => "self.page",
    },
);
__PACKAGE__->has_many(
    "page_version_page_content_version_firsts",
    "MojoMojo::Schema::Result::PageVersion",
    {
        "foreign.content_version_first" => "self.version",
        "foreign.page"                  => "self.page",
    },
);
__PACKAGE__->has_many(
    "page_version_page_content_version_lasts",
    "MojoMojo::Schema::Result::PageVersion",
    {
        "foreign.content_version_last" => "self.version",
        "foreign.page"                 => "self.page",
    },
);
__PACKAGE__->belongs_to(
    "creator",
    "MojoMojo::Schema::Result::Person",
    { id => "creator" }
);
__PACKAGE__->belongs_to(
    "page",
    "MojoMojo::Schema::Result::Page",
    { id => "page" }
);


=head1 COLUMNS

=head2 page

References L<MojoMojo::Schema::Result::Page>.

=head2 creator

References L<MojoMojo::Schema::Result::Person>.


=head1 METHODS

=head2 highlight

Returns an HTML string highlighting the changes between this version and the
previous version. The changes are in C<< <span> >> or C<< <div> >> tags with
the class C<fade>.

=cut

sub highlight {
    my ( $self, $c ) = @_;
    my $this_content = $self->formatted($c);

    my $previous_content = (
        defined $self->previous
        ? $self->previous->formatted($c)
        : $this_content
    );

    my $this = [ split /\n/, $this_content ];
    my $prev = [ split /\n/, $previous_content ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    my $hi           = 0;
    my $pre_tag_open = 0;
    for my $line (@diff) {
        $pre_tag_open = 1 if $$line[2] =~ qr{<pre>} and $$line[2] !~ qr{</pre>};
        my $tag = $pre_tag_open ? 'span' : 'div';
        $hi++;
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<$tag id="hi$hi" class="fade">) . $$line[2] . "</$tag>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<$tag id="hi$hi" class="fade">) . $$line[2] . "</$tag>";
        }
        elsif ( $$line[0] eq "-" ) { }
        else                       { $diff .= $$line[1] }
        $diff .= "\n";
        $pre_tag_open = 0 if $$line[2] =~ qr{</pre>} and $$line[2] !~ qr{<pre>};
    }
    return $diff;
}

=head2 formatted_diff <context> <old_content>

Compare this content version to <old_content>, using L<Algorithm::Diff>.
Sets a C<diffins> CSS class for added lines, and a C<diffdel> CSS class
for deleted lines. The C<< <ins> >> and C<< <del> >> HTML tags are also used.

=cut

sub formatted_diff {
    my ( $self, $c, $to, $sparse ) = @_;
    my $this = [
        $sparse
        ? split /\n/,
        ( $self->encoded_body )
        : split /\n\n/,
        ( $self->formatted($c) )
    ];
    my $prev = [
        $sparse
        ? split /\n/,
        ( $to->encoded_body )
        : split /\n\n/,
        ( $to->formatted($c) )
    ];
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

            $diff .= (
                $sparse
                ? qq(<div class="diffdel">)
                  . $$line[1]
                  . "</div>"
                  . qq(<div class="diffins">)
                  . $$line[2]
                  . "</div>"
                : String::Diff::diff_merge(
                    $$line[1], $$line[2],
                    remove_open  => '<del>',
                    remove_close => '</del>',
                    append_open  => '<ins>',
                    append_close => '</ins>',
                )
            );
        }
        elsif ( $$line[0] eq "u" ) {
            $diff .= ( $sparse ? '<div> ' . $$line[1] . '<div>' : $$line[1] );
        }
        else { $diff .= "Unknown operator " . $$line[0] }
    }
    return $diff;
}

=head2 formatted

Return the content after being run through MojoMojo::Formatter::*.

=cut

sub formatted {
    my ( $self, $c ) = @_;
    my $result =
      $self->result_source->resultset->format_content( $c, $self->body, $self );
    return $result;
}

sub merge_content {
    my ( $self, $saved, $content, $h1, $h2, $h3 ) = @_;

    my $source = [ split /\n/, $self->encoded_body ];
    my $a      = [ split /\n/, $saved->encoded_body ];
    my $b      = [ split /\n/, $content ];
    my @merged = merge(
        $source, $a, $b,
        {
            CONFLICT => sub ($$) {
                (
                    "<!-- $h1  -->\n",
                    ( @{ $_[0] } ),
                    "<!-- $h2  -->\n",
                    ( @{ $_[1] } ),
                    "<!-- $h3 -->\n",
                );
              }
        }
    );
    return join( '', @merged );
}

=head2 max_version

Return the highest numbered revision.

=cut

sub max_version {
    my $self = shift;
    my $max  = $self->result_source->resultset->search(
        { page => $self->page->id },
        {
            select => [ { max => 'me.version' } ],
            as     => ['max_ver']
        }
    );
    return 0 unless $max->count;
    return $max->next->get_column('max_ver');
}

=head2 previous

Return the previous version of this content, or undef for the first version.

=cut

sub previous {
    my $self = shift;
    return $self->result_source->resultset->search(
        {
            page    => $self->page->id,
            version => $self->version - 1
        }
    )->next;
}

=head2 pub_date

Return the publishing date of this version in a format suitable for RSS 2.0.

=cut

sub pub_date {
    my $self = shift;
    return DateTime::Format::Mail->format_datetime( $self->created );
}

=head2 store_links

Extract and store all links and wanted paged from a given content
version.

=cut

use Data::Dumper;

sub store_links {
    my ($self) = @_;
    return unless ( $self->status eq 'released' );
    my $content = $self->body;
    my $page    = $self->page;
    $page->result_source->resultset->set_paths($page);
    $page->links_from->delete();
    $page->wantedpages->delete();
    require MojoMojo::Formatter::Wiki;
    my ( $linked_pages, $wanted_pages ) =
      MojoMojo::Formatter::Wiki->find_links( \$content, $page );
    return unless ( @$linked_pages || @$wanted_pages );

    for (@$linked_pages) {
        my $link =
          $self->result_source->schema->resultset('Link')
          ->find_or_create(
            { from_page => $self->page->id, to_page => $_->id } );
    }
    for (@$wanted_pages) {
        my $wanted_page =
          $self->result_source->schema()->resultset('WantedPage')
          ->find_or_create( { from_page => $page->id, to_path => $_->{path} } );
    }
}

sub encoded_body { return encode_entities_numeric( shift->body ); }

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
