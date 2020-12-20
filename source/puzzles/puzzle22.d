module puzzles.puzzle22;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism : parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

/// 
void solve_22_1()
{
    {
        auto parser = new InputParser();
        readFileLineByLine("input/input_22.text", (string line) {
            parser.reset(line);
            if (line.length == 0)
                return;

        });
    }
}

/// 
void solve_22_2()
{
}
