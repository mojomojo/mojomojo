package MojoMojo::C::Export;
use strict;
use base 'Catalyst::Base';
use Time::Piece;
use Archive::Zip;

my $model='MojoMojo::M::Core::Page';

=head1 NAME

MojoMojo::C::Export - Export / Import related controller

=head1 SYNOPSIS


=head1 DESCRIPTION

MojoMojo has an extensive export system. You can download all the 
nodes of the wiki either as preformatted HTML, for offline reading
or in a raw format suitable for reimporting into another MojoMojo
installation. either way, MojoMojo will create and send you a zip 
file with a directory containing all the files. the filename of the
directory will contain a timestamp showing when the archive was made.

=head1 ACTIONS

=over 4

=item index

This action just shows an overview of the export features.

=cut

sub index : Path('/.export') {
        my ( $self, $c ) = @_;
        $c->stash->{template} ='export.tt'
}

=item raw (/.export.zip)

This action will give you a zip file containing the raw wiki source
for all the nodes of the wiki.

=cut

sub raw : Path('/.export.zip') {
    my ( $self, $c ) = @_;
    my @pages=$model->retrieve_all_sorted_by("node");
    my $archive=Archive::Zip->new();
    my $prefix=$c->fixw($c->pref('name')).
        "-export-".localtime->ymd('-').'-'.localtime->hms('-');
    $archive->addDirectory("$prefix/");
    for my $page (@pages) {
        $archive->addString($page->content, $prefix."/".$page->node);
    }
    my $fh=IO::Scalar->new(\$c->res->{output});
    $archive->writeToFileHandle($fh);
    $c->res->headers->header("Content-Type" => 'archive/zip');
    $c->res->headers->header("Content-Disposition" =>
       "attachment; filename=$prefix.zip");
}

=item html (/.html.zip)

This action will give you a zip file containing HTML formatted 
versions of all the nodes of the wiki.

=cut

sub html : Path('/.html.zip') {
        my ( $self, $c ) = @_;
        my @pages=$model->retrieve_all_sorted_by("node");
        my $archive=Archive::Zip->new();
        my $prefix=$c->fixw($c->pref('name')).
        "-html-".localtime->ymd('-').'-'.localtime->hms('-');
        $archive->addDirectory("$prefix/");
        my $home=$c->pref("home_node");
        $archive->addString(qq{ <html><head>
  <META HTTP-EQUIV="Refresh" CONTENT="0;URL=$home">
    </head></html>},$prefix."/index.html");
        for my $page (@pages) {
          $archive->addString($c->subreq("!page/print",$page->node),
                              $prefix."/".$page->node);
        }
    my $fh=IO::Scalar->new(\$c->res->{output});
    $archive->writeToFileHandle($fh);
    $c->res->headers->header("Content-Type" => 'archive/zip');
    $c->res->headers->header("Content-Disposition" =>
       "attachment; filename=$prefix.zip");
}

1;
