#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 85;

use Test::Differences;

use Games::Nurikabe::Solver::Cell;
use Games::Nurikabe::Solver::Constants qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Board;

sub verdict_cells
{
    my ($m, $verdict) = @_;

    return [map { $_->to_aref() } @{$m->get_verdict_cells($verdict)} ];
}

sub _base_coords
{
    my ($m) = @_;

    return $m->reason_param("base_coords")->to_aref;
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

    # TEST
    is ($board->_num_expected_cells($NK_WHITE), 1, "Expecting 1 White Cell");

    # TEST
    is ($board->_num_expected_cells($NK_BLACK), 3, "Expecting 3 Black Cells");

    # TEST
    is ($board->_num_found_cells($NK_WHITE), 1, "Found 1 White Cells");

    # TEST
    is ($board->_num_found_cells($NK_BLACK), 0, "Found 0 Black Cells");

    # TEST
    is ($board->_num_found_cells($NK_UNKNOWN), 3,
        "Currently have 3 unknown cells"
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

        # TEST
        is ($board->_num_found_cells($NK_WHITE), 1, "Found 1 White Cells");

        # TEST
        is ($board->_num_found_cells($NK_BLACK), 2, "Found 2 Black Cells");

        # TEST
        is ($board->_num_found_cells($NK_UNKNOWN), 1,
            "Currently have 1 unknown cells"
        );
    }

    {
        my $moves = $board->_solve_using(
            {
                name => "surrounded_by_blacks",
                params => {},
            });

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

{
    my $string_representation = <<"EOF";
Width=3 Height=3
[] []  []
[] [1] []
[] []  []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    # TEST
    is ($board->_num_expected_cells($NK_WHITE), 1, "Expecting 1 White Cell");

    # TEST
    is ($board->_num_expected_cells($NK_BLACK), 8, "Expecting 3 Black Cells");

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
            [[0,1],[1,0], [1,2], [2,1]],
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

        my $m;

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 0 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[0,0]],
            "Verdicted cells for 0 is OK.",
        );

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 1 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[0,2]],
            "Verdicted cells for 1 is OK.",
        );

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 2 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[2,0]],
            "Verdicted cells for 2 is OK.",
        );

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 3 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[2,2]],
            "Verdicted cells for 3 is OK.",
        );

        # TEST
        eq_or_diff(
            $moves,
            [],
            "No more moves left",
        );
    }
}

{
    # http://www.logicgamesonline.com/nurikabe/archive.php?pid=983
    # Daily 9*9 Nurikabe for 2008-10-03
    my $string_representation = <<"EOF";
Width=9 Height=9
[1] [] [] [] [] [] [] [5] []
[] [6] [] [] [6] [] [] [] []
[] []  [] [3] [] [] [] [] []
[] [] [] [] [] [] [] [] []
[] [] [] [] [] [] [] [] []
[] [] [] [] [] [] [] [] []
[] [] [] [] []  [2] [] [] []
[] [] [] [] [3] [] [] [3] []
[] [2] [] [] [] [] [] [] [1]
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    # TEST
    is ($board->_num_expected_cells($NK_WHITE), 1+5+6+6+3+2+3+3+2+1,
        "Expected white cells");

    # TEST
    is ($board->_num_expected_cells($NK_BLACK), 9*9-(1+5+6+6+3+2+3+3+2+1),
        "Expected black cells"
    );

    {
        my $moves = $board->_solve_using(
            {
                name => "adjacent_whites",
                params => {},
            }
        );

        my $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[0] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[0,1],[1,0]],
            "Verdicted cells[0] are OK.",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [1,1], "Offset[0] is (1,1).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [0,2],
            "Islands of [0] are [0,2]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [0,0],
            "Base coords[0] is (0,0)."
        );

        $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[1] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[1,3],[2,4]],
            "Verdicted cells[1] are OK.",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [1,-1], "Offset[1] is (1,-1).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [3,4],
            "Islands of [1] are [3,4]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [1,4],
            "Base coords[1] is (1,4)."
        );

        $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[2] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[6,4],[7,5]],
            "Verdicted cells[2] are OK.",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [1,-1], "Offset[2] is (1,-1).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [5,6],
            "Islands of [2] are [5,6]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [6,5],
            "Base coords[2] is (6,5)."
        );

        $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[3] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[7,8],[8,7]],
            "Verdicted cells[3] are OK.",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [1,1], "Offset[3] is (1,1).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [7,9],
            "Islands of [3] are [7,9]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [7,7],
            "Base coords[3] is (7,7)."
        );

        # TEST
        eq_or_diff (
            $moves,
            [],
            "No more moves left."
        );

    }
}

{
    # http://www.logicgamesonline.com/nurikabe/archive.php?pid=981
    # Daily 9*9 Nurikabe for 2008-10-01
    my $string_representation = <<"EOF";
Width=9 Height=9
[]  []  []  []  []  [3] []  []  []
[]  [1] []  [5] []  []  []  []  []
[]  []  []  []  []  []  []  []  []
[]  []  []  []  [1] []  []  []  []
[]  []  []  []  []  []  []  []  []
[]  []  []  []  [6] []  []  []  []
[]  []  []  []  []  []  []  []  []
[]  []  []  []  []  [8] []  [7] []
[]  []  []  [2] []  []  []  []  []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    {
        my $moves = $board->_solve_using(
            {
                name => "adjacent_whites",
                params => {},
            }
        );

        my $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[0] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[1,2]],
            "Verdicted cells[0] are [[1,2]].",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [0,2], "Offset[0] is (0,2).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [1,2],
            "Islands of [0] are [1,2]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [1,1],
            "Base coords[0] is (1,1)."
        );

        $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[1] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[4,4]],
            "Verdicted cells[1] are [[4,4]].",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [2,0], "Offset[1] is (2,0).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [3,4],
            "Islands of [1] are [3,4]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [3,4],
            "Base coords[0] is (3,4)."
        );

        $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[2] is OK.");

        # TEST
        eq_or_diff(
            verdict_cells($m, $NK_BLACK),
            [[7,6]],
            "Verdicted cells[2] are [[7,6]].",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [0,2], "Offset[2] is (0,2).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [5,6],
            "Islands of [2] are [5,6]",
        );

        # TEST
        eq_or_diff (
            _base_coords($m),
            [7,5],
            "Base coords[0] is (7,5)."
        );

        # TEST
        eq_or_diff ($moves, [], "No more moves left.");
    }
}

package MyMove;

use base 'Games::Nurikabe::Solver::Base';

use List::MoreUtils qw(any);

use Games::Nurikabe::Solver::Constants qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Cell;

__PACKAGE__->mk_acc_ref([qw(move)]);

sub _init
{
    my ($self, $args) = @_;

    $self->move($args->{move});

    return;
}

sub in_black
{
    my ($self, $coords) = @_;

    return (any { $_->y == $coords->[0] && $_->x == $coords->[1] }
           @{$self->move->get_verdict_cells($NK_BLACK)})
       ;
}

sub in_white
{
    my ($self, $coords) = @_;

    return (any { $_->y == $coords->[0] && $_->x == $coords->[1] }
           @{$self->move->get_verdict_cells($NK_WHITE)})
       ;
}

sub multi_in_white
{
    my ($self, $list_of_coords) = @_;

    my @not_found = (grep { !$self->in_white($_) } @$list_of_coords);

    if (! @not_found)
    {
        return '';
    }
    else
    {
        return 'Coordinates [ ' .
            join(" , ", map { '['.join(',',@$_) . ']' } @not_found)
            . ' ] were not marked as white in this move.'
            ;
    }
}

sub reason
{
    my $self = shift;

    return $self->move->reason();
}

package main;

{
    # http://www.logicgamesonline.com/nurikabe/archive.php?pid=981
    # Daily 9*9 Nurikabe for 2008-10-01
    my $string_representation = <<"EOF";
Width=9 Height=9
[]  []  []  []  []  [3] []  []  []
[]  [1] []  [5] []  []  []  []  []
[]  []  []  []  []  []  []  []  []
[]  []  []  []  [1] []  []  []  []
[]  []  []  []  []  []  []  []  []
[]  []  []  []  [6] []  []  []  []
[]  []  []  []  []  []  []  []  []
[]  []  []  []  []  [8] []  [7] []
[]  []  []  [2] []  []  []  []  []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    {
        my $moves = $board->_solve_using(
            {
                name => "distance_from_islands",
                params => {},
            }
        );

        my $m = MyMove->new({move => shift(@$moves)});

        # TEST
        eq_or_diff(
            $moves,
            [],
            "No remaining moves except the first one."
        );

        # TEST
        is ($m->reason(), "distance_from_islands", "Reason is OK.");

        # TEST
        ok (
            $m->in_black([7,0]),
            "Marked Cells contain (7,0)",
        );

        # TEST
        ok (
            $m->in_black([8,0]),
            "Marked Cells contain (8,0)",
        );

        # TEST
        ok (
            $m->in_black([8,1]),
            "Marked Cells contain (8,1)",
        );

        # TEST
        ok (
            $m->in_black([0,8]),
            "Marked Cells contain (0,8)",
        );

        # TEST
        ok (
            $m->in_black([2,0]),
            "Marked Cells contain (8,1)",
        );

        # TEST
        ok (
            !$m->in_black([5,1]),
            "Marked Cells does not contain (5,1) which is accessible",
        );

        # TEST
        ok (
            !$m->in_black([3,6]),
            "Marked Cells does not contain (3,6) which is accessible",
        );
    }
}

{
    # http://www.logicgamesonline.com/nurikabe/archive.php?pid=981
    # Daily 9*9 Nurikabe for 2008-10-01
    my $string_representation = <<"EOF";
Width=5 Height=5
[] [6] [] [] []
[] [] [] [2] []
[] [] [] [] []
[] [1] [] [] []
[] [] [] [2] []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    $board->_solve_using(
        {
            name => "surround_island",
            params => {},
        }
    );

    $board->_solve_using(
        {
            name => "surrounded_by_blacks",
            params => {},
        }
    );

    $board->_solve_using(
        {
            name => "distance_from_islands",
            params => {},
        }
    );

    my $moves = $board->_solve_using(
        {
            name => "fully_expand_island",
            params => {},
        }
    );

    my $m = MyMove->new({move => shift(@$moves)});

    # TEST
    eq_or_diff(
        $moves,
        [],
        "No remaining moves except the first one."
    );

    my $verdict = $m->multi_in_white([[0,0],[0,2],[1,0],[1,1],[2,0]]);

    # TEST
    if (! ok (!$verdict, "All fully_expand_island white cells are there."))
    {
        diag($verdict);
    }
}

# Test expand_black_regions.

{
    my $string_representation = <<"EOF";
Width=5 Height=5
[] [6] [] [] []
[] [] [] [2] []
[] [] [] [] []
[] [1] [] [] []
[] [] [] [2] []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    # First solve using the existing methods until there are no moves left.
    my $found_moves = 1;

    while ($found_moves)
    {
        $found_moves = 0;

        foreach my $method (qw(
            surround_island
            surrounded_by_blacks
            adjacent_whites
            distance_from_islands
            fully_expand_island
            )
        )
        {
            my $moves = $board->_solve_using(
                {
                    name => $method,
                    params => {},
                }
            );

            if (@$moves)
            {
                $found_moves = 1;
            }
        }
    }

    my $moves = $board->_solve_using(
        {
            name => "expand_black_regions",
            params => {},
        }
    );

    my $m = MyMove->new({move => shift(@$moves)});

    # TEST
    eq_or_diff(
        $moves,
        [],
        "No remaining moves except the first one."
    );

    # TEST
    is ($m->reason(), "expand_black_regions", "Reason is OK.");

    # TEST
    ok (
        $m->in_black([1,4]),
        "Expanded cells contain (1,4)",
    );

    # TEST
    ok (
        $m->in_black([4,2]),
        "Expanded cells contain (4,2)",
    );
}

# Test the expand_black_regions does not expand when all the black cells are
# fully connected, because otherwise these cells may be white.
{
    my $string_representation = <<"EOF";
Width=5 Height=5
[] [6] [] [] []
[] [] [] [2] []
[] [] [] [] []
[] [1] [] [] []
[] [] [] [2] []
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    foreach my $method (qw(
        surround_island
        surrounded_by_blacks
        distance_from_islands
        fully_expand_island
        expand_black_regions
        adjacent_whites
        expand_black_regions
        fully_expand_island
        expand_black_regions
        ))
    {
        my $moves = $board->_solve_using( { name => $method } );

        if (!@$moves)
        {
            die "No moves for method $method.";
        }
    }

    my $moves = $board->_solve_using(
        {
            name => "expand_black_regions",
            params => {},
        }
    );

    # TEST
    eq_or_diff (
        $moves,
        [],
        "No moves were done as the black region is fully connected."
    );
}
