package MojoMojo::C::Export;
use strict;
use base 'Catalyst::Base';
use Time::Piece;

my $model='MojoMojo::M::Core::Page';

MojoMojo->action (
    '.export.zip' => sub {
        my ( $self, $c ) = @_;

		},
		'.html.zip' => sub {
        my ( $self, $c ) = @_;
        my @pages=$model->retrieve_all_sorted_by("node");
        my $archive=Archive::Zip->new();
        my $prefix=$c->fixw($c->pref('application_name')).
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
});
1;
