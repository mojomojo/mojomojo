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

        $c->stash->{template} = 'page/view.tt';

        $c->form( optional => ['rev'] );

        $node ||= $c->prefs('home_page');
        my $page = MojoMojo::M::CDBI::Page->get_page( $node );
        return $c->forward('?edit') unless $page;

        if ( my $rev = $c->form->valid('rev') ) {
            $c->stash->{rev} = abs $rev;

            my @revs = $page->revisions;
            if ( scalar @revs >= $rev ) {
                $c->stash->{objects} = [ $revs[ $rev - 1 ], $revs[$rev] ];
                $c->stash->{rev_nr} = $rev;
            }
            else { $c->stash->{template} = 'norevision.tt' }

        }
        else {
            $c->stash->{rev} = 0;
            $c->stash->{pages} = [ $page, $page->revisions->next ];
        }

    },

    '!page/edit' => sub {
        my ( $self, $c, $node ) = @_;

        $c->stash->{template} = 'page/edit.tt';

        my $class = 'MojoMojo::M::CDBI::Page';
        my $page = $class->get_page( $node );
        $c->stash->{page} = $page;

        $c->req->params->{node} ||= $node;
        $c->form( optional => ['tags'], required => [qw/node content/] );

        return if ( $c->form->has_missing || $c->form->has_invalid );

        $page
          ? $page->update_from_form( $c->form )
          : $class->create_from_form( $c->form );

        $c->forward('?view');

    },

);

1;
