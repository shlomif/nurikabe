#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

use Test::Differences;

use Games::Nurikabe::Solver::Cell;
use Games::Nurikabe::Solver::Constants qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);

use Games::Nurikabe::Solver::Board;

use List::MoreUtils qw(any);

sub verdict_cells
{
    my ($m, $verdict) = @_;

    return [map { $_->to_aref() } @{$m->get_verdict_cells($verdict)} ];
}

{
    my $string_representation = <<"EOF";
Width=2 Height=2
[1] []
[]  []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    {
        my $moves = $board->_solve_using(
            {
                name => "surround_island",
                params => {},
            }
        );

        # TEST
        is (scalar(@$moves), 1, "There is 1 move");

        my $m = $moves->[0];

        # TEST
        is ($m->reason(), "surround_island_when_full", "reason is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[0,1],[1,0]],
            "Verdicted cells is OK.",
        );

        # TEST
        is ($m->reason_param("island"), 0,
            "The island is 0 in the reason parameter",
        );
    }

    {
        my $moves = $board->_solve_using(
            {
                name => "surrounded_by_blacks",
                params => {},
            }
        );

        # TEST
        is (scalar(@$moves), 1, "There is 1 move");

        my $m = $moves->[0];

        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[1,1]],
            "Verdicted cells is OK.",
        );
    }
}
