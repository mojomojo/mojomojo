package MojoMojo::Model::Search::Plucene;

use strict;

BEGIN {

eval "use base qw/Catalyst::Model::Search::Plucene/;use Plucene::Plugin::Analyzer::SnowballAnalyzer";

if ($@) {
    our @ISA=qw/Catalyst::Model::Search/;
};

};

__PACKAGE__->config(
    index    => MojoMojo->config->{home} . '/plucene',
    analyzer => 'Plucene::Plugin::Analyzer::SnowballAnalyzer',
);

=item prepare_search_index

Create a new search index from all pages in the database.
Will do nothing if the index already exists.

=cut

sub prepare_search_index {
   my $self = shift;
   my $index = $self->config->{index};
   
   # is the root page already indexed?
   return if ( $self->is_indexed( '/' ) );

   MojoMojo->log->info( "Initializing Plucene search index..." ) 
       if MojoMojo->debug;

   # loop through all latest-version pages
   my $count = 0;
   my $it = MojoMojo::M::Core::Page->retrieve_all;
   while ( my $page = $it->next ) {
       $page->set_paths( $page );
       $self->index_page( $page );
       $count++;
   }

   $self->optimize;

   MojoMojo->log->info( "Indexed $count pages" ) if MojoMojo->debug;
}

=item index_page <page>

Create/update the search index with data from a MojoMojo page.

=cut

# updates the search index when page data changes
sub index_page {
   my ( $self, $page ) = @_;
   return unless ( $page && $page->content );
   return unless $self->isa('Catalyst::Model::Search::Plucene');

   my $content = $page->content;
   my $key = $page->path;

   my $text = $content->body;
   $text .= " " . $content->abstract if ( $content->abstract );
   $text .= " " . $content->comments if ( $content->comments );

   # translate the path into plain text so we can use it in the search query later
   my $fixed_path = $key;
   $fixed_path =~ s{/}{X}g;

   # FIXME: Should author here reflect last edit?
   my $data = {
       _author => $content->creator->login,
       _path => $fixed_path,
       date => ($content->created) ? $content->created->ymd : '',
       tags => join (' ', map { $_->tag } $page->tags ),
       text => $text,
   };
   
   $self->update( { $key => $data } );
}

1;
