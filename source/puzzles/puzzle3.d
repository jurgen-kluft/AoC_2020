module puzzles.puzzle3;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.stdc.string : strlen;
import utilities.inputparser;

struct row
{
    int[] data;
}

struct slope
{
    int dx;
    int dy;
}

/// 
void solve_3_1()
{
    auto parser = new InputParser();
    row[] forest;

    // #...#...##..##........#........
    readFileLineByLine("input/input_3.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        
        row r;
        while (!parser.at_end())
        {
            char place;
            parser.read(place);
            if (place == '.')
                r.data ~= 0;
            else
                r.data ~= 1;
        }
        //writeln("  -> row=", r.data);
        forest ~= r;
    });

    slope[] slopes;
    slope s1 = {dx:3, dy:1};
    slopes ~= s1;

    foreach(s; slopes)
    {
        int step_x = s.dx;
        int step_y = s.dy;
        int x = step_x;
        int y = step_y;

        int trees = 0;
        while (y < forest.length)
        {
            int frow = y;
            int fcol = x % (cast(int)forest[frow].data.length);
            if (forest[frow].data[fcol] == 1)
            {
                trees++;
            }

            x += step_x;
            y += step_y;
        }
        writeln("1: number of trees: ", trees);
    }
}

/// 
void solve_3_2()
{
    auto parser = new InputParser();
    row[] forest;

    // #...#...##..##........#........
    readFileLineByLine("input/input_3.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        
        row r;
        while (!parser.at_end())
        {
            char place;
            parser.read(place);
            if (place == '.')
                r.data ~= 0;
            else
                r.data ~= 1;
        }
        //writeln("  -> row=", r.data);
        forest ~= r;
    });

    slope[] slopes;
    slope s1 = {dx:1, dy:1};
    slopes ~= s1;
    slope s2 = {dx:3, dy:1};
    slopes ~= s2;
    slope s3 = {dx:5, dy:1};
    slopes ~= s3;
    slope s4 = {dx:7, dy:1};
    slopes ~= s4;
    slope s5 = {dx:1, dy:2};
    slopes ~= s5;

    long trees_multiplied = 1;
    foreach(s; slopes)
    {
        int step_x = s.dx;
        int step_y = s.dy;
        int x = step_x;
        int y = step_y;

        int trees = 0;
        while (y < forest.length)
        {
            int frow = y;
            int fcol = x % (cast(int)forest[frow].data.length);
            if (forest[frow].data[fcol] == 1)
            {
                trees++;
            }

            x += step_x;
            y += step_y;
        }
        trees_multiplied *= trees;
    }

    writeln("2: multiple number of trees multiplied: ", trees_multiplied);
}
