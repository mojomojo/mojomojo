package MojoMojo::C::Page;

use strict;
use base 'Catalyst::Base';
use Algorithm::Diff;
use Archive::Zip;
use IO::Scalar;
use URI;

MojoMojo->action(

    '!page/view' => sub {
        my ( $self, $c, $node ) = @_;

        $c->stash->{template} ||= 'page/view.tt';

        $c->form( optional => ['rev'] );

        $node ||= $c->pref('home_node');
        my $page = MojoMojo::M::Core::Page->get_page( $node );
        return $c->forward('!page/edit') unless $page;

        if ( my $rev = $c->form->valid('rev') ) {
            $c->stash->{rev} = abs $rev;

            my @revs = $page->revisions;
            if ( scalar @revs >= $rev ) {
                $c->stash->{page} =  $revs[ $rev - 1 ];
                $c->stash->{rev} = $rev;
            }
            else { $c->stash->{template} = 'norevision.tt' }

        }
        else {
            $c->stash->{rev} = 0;
            $c->stash->{page} =  $page;
        }

    },

    '!page/edit' => sub {
        my ( $self, $c, $node ) = @_;

        $c->stash->{template} = 'page/edit.tt';

        my $class = 'MojoMojo::M::Core::Page';
        my $page = $class->get_page( $node );
        $c->stash->{page} = $page;

        $c->req->params->{node} ||= $node;
        $c->form( optional => ['tags'], required => [qw/node content/] );

        return if ( $c->form->has_missing || $c->form->has_invalid );

        $page
          ? $page->update_from_form( $c->form )
          : $class->create_from_form( $c->form );

        $c->forward('?view');

    }, '!page/print' => sub {
        my ( $self, $c, $node ) = @_;
        $c->stash->{template} = 'page/print.tt';
	$c->forward('!page/view');
    }, '!page/rss' => sub {
        my ( $self, $c, $node ) = @_;
        $c->stash->{template} = 'page/rss.tt';
	$c->forward('!page/view');
    }, '!page/atom' => sub {
        my ( $self, $c, $node ) = @_;
        $c->stash->{template} = 'page/atom.tt';
	$c->forward('!page/view');
    }, '!page/rss' => sub {
        my ( $self, $c, $node ) = @_;
        $c->stash->{template} = 'page/rss_full.tt';
	$c->forward('!page/view');
    }

);

1;
