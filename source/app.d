import std.stdio;
import puzzles.puzzle1;
import puzzles.puzzle2;

void main()
{
    import utilities.stringparser : test_stringparser;

    test_stringparser();

    solve_1_1();
    solve_1_2();

    solve_2_1();
    solve_2_2();
}
