module puzzles.puzzle11;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

alias u64 = ulong;

const byte EMPTY = 0;
const byte OCCUPIED = 1;
const byte WALL = 2;
const byte FLOOR = 9;

int countAdjacentSeatsOfType(byte[][] grid, int r, int c, byte type)
{
    int count = 0;
    for (int ro=-1; ro<2; ro+=1)
    {
        for (int co=-1; co<2; co+=1)
        {
            if (ro == 0 && co == 0)
                continue;

            byte s = grid[r + ro][c + co];
            if (s == type)
            {
                count += 1;
            }
        }
    }
    return count;
}

int countVisibleSeatsOfType(byte[][] grid, int r, int c, byte type)
{
    int count = 0;
    for (int ro=-1; ro<2; ro+=1)
    {
        for (int co=-1; co<2; co+=1)
        {
            if (ro == 0 && co == 0)
                continue;

            int vr = r + ro;
            int vc = c + co;
            while (grid[vr][vc] == FLOOR)
            {
                // Look further
                vr += ro;
                vc += co;
            }

            byte s = grid[vr][vc];
            if (s == type)
            {
                count += 1;
            }
        }
    }
    return count;
}

struct change
{
    int row;
    int col;
    byte state;
}

/// 
void solve_11_1()
{
    byte[][] grid;
    
    // 1st row and last row we push in WALL
    byte[] top;
    byte[] bottom;
    grid ~= top;

    auto parser = new InputParser();
    readFileLineByLine("input/input_11.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        // start and end of every row we push in WALL
        byte[] r;
        r ~= WALL;
        foreach(c; line)
        {
            switch (c)
            {
                case 'L':
                    r ~= EMPTY;
                    break;
                case '.':
                    r ~= FLOOR;
                    break;
                default:
                    break;
            }
        }
        r ~= WALL;

        grid ~= r;
    });
    for (size_t i=0; i<grid[1].length; i+=1)
    {
        top ~= WALL;
        bottom ~= WALL;
    }
    grid[0] = top;
    grid ~= bottom;

    //writeln("Grid dimensions = W:", grid[1].length, " by H:", grid.length);
    //foreach(r; grid)
    //{
    //    writeln(r);
    //}

    // Without the start/end extra WALL
    int numrows = cast(int)grid.length - 1;
    int numcols = cast(int)grid[0].length - 1;

    int iterations = 0;
    while (true)
    {
        iterations += 1;
        change[] changes;
        for (int r=1; r<numrows; r+=1)
        {
            for (int c=1; c<numcols; c+=1)
            {
                if (grid[r][c] == OCCUPIED)
                {
                    // If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
                    int adjacent_occupied = countAdjacentSeatsOfType(grid, r, c, OCCUPIED);
                    if (adjacent_occupied >= 4)
                    {
                        change cc = { row: r, col: c, state: EMPTY };
                        changes ~= cc;
                    }
                }
                else if (grid[r][c] == EMPTY)
                {
                    // If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
                    int adjacent_occupied = countAdjacentSeatsOfType(grid, r, c, OCCUPIED);
                    if (adjacent_occupied == 0)
                    {
                        change cc = { row: r, col: c, state: OCCUPIED };
                        changes ~= cc;
                    }
                }
            }
        }

        // Apply changes
        foreach(cc; changes)
        {
            grid[cc.row][cc.col] = cc.state;
        }

        if (changes.length == 0)
            break;
    }
    //writeln("Number of iterations: ", iterations);

    // Count the number of seats
    int num_occupied = 0;
    for (int r=1; r<numrows; r+=1)
    {
        for (int c=1; c<numcols; c+=1)
        {
            if (grid[r][c] == OCCUPIED)
            {
                num_occupied += 1;
            }
        }
    }

    writeln("1: Occupied = ", num_occupied);
}

/// 
void solve_11_2()
{
    byte[][] grid;
    
    // 1st row and last row we push in WALL
    byte[] top;
    byte[] bottom;
    grid ~= top;

    auto parser = new InputParser();
    readFileLineByLine("input/input_11.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        // start and end of every row we push in WALL
        byte[] r;
        r ~= WALL;
        foreach(c; line)
        {
            switch (c)
            {
                case 'L':
                    r ~= EMPTY;
                    break;
                case '.':
                    r ~= FLOOR;
                    break;
                default:
                    break;
            }
        }
        r ~= WALL;

        grid ~= r;
    });
    for (size_t i=0; i<grid[1].length; i+=1)
    {
        top ~= WALL;
        bottom ~= WALL;
    }
    grid[0] = top;
    grid ~= bottom;

    //writeln("Grid dimensions = W:", grid[1].length, " by H:", grid.length);
    //foreach(r; grid)
    //{
    //    writeln(r);
    //}

    // Without the start/end extra WALL
    int numrows = cast(int)grid.length - 1;
    int numcols = cast(int)grid[0].length - 1;

    int iterations = 0;
    while (true)
    {
        iterations += 1;
        change[] changes;
        for (int r=1; r<numrows; r+=1)
        {
            for (int c=1; c<numcols; c+=1)
            {
                if (grid[r][c] == OCCUPIED)
                {
                    // If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
                    int adjacent_occupied = countVisibleSeatsOfType(grid, r, c, OCCUPIED);
                    if (adjacent_occupied >= 5)
                    {
                        change cc = { row: r, col: c, state: EMPTY };
                        changes ~= cc;
                    }
                }
                else if (grid[r][c] == EMPTY)
                {
                    // If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
                    int adjacent_occupied = countVisibleSeatsOfType(grid, r, c, OCCUPIED);
                    if (adjacent_occupied == 0)
                    {
                        change cc = { row: r, col: c, state: OCCUPIED };
                        changes ~= cc;
                    }
                }
            }
        }

        // Apply changes
        foreach(cc; changes)
        {
            grid[cc.row][cc.col] = cc.state;
        }

        if (changes.length == 0)
            break;
    }
    //writeln("Number of iterations: ", iterations);

    // Count the number of seats
    int num_occupied = 0;
    for (int r=1; r<numrows; r+=1)
    {
        for (int c=1; c<numcols; c+=1)
        {
            if (grid[r][c] == OCCUPIED)
            {
                num_occupied += 1;
            }
        }
    }

    writeln("2: Occupied = ", num_occupied);    
}