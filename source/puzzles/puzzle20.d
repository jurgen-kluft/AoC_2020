module puzzles.puzzle20;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism : parallel;
import core.stdc.string : strlen;

import utilities.inputparser;
import parser = utilities.parser2;

class Tile
{
    int ID;
    uint[] Row;
}

uint ParseBinary(string line)
{
    uint val = 0;
    foreach(c; line)
    {
        val = val << 1;
        if (c == '#')
            val = val | 1;
    }
    return val;
}

void PrintTile(Tile tile)
{
    writeln("Tile: ", tile.ID);
    foreach(row; tile.Row)
    {
        write("    ");
        for(int i=9; i>=0; i-=1)
        {
            if ((row & (1<<i)) == 0)
                write('.');
            else
                write('#');
        }
        writeln();
    }
    writeln();
}

/// 
void solve_20_1()
{
    // Tile 3583:
    // .##..#..#.
    // ....##....
    // ##..#..#..
    // .....#....
    // .#..#.....
    // #.#.......
    // #.....#..#
    // ....#....#
    // ...#.##.#.
    // .#....##.#

    // Puzzle is a 12 x 12 board
    
    string[] lines;
    readFileLineByLine("input/input_20.text", (string line) {
        lines ~= line;
    });

    parser.Var tileIndex = new parser.Var();
    parser.Seq tileHeader = new parser.Seq(
        new parser.Exact("Tile"),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.Index(tileIndex),
        new parser.Is(':'),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.EOL()
    );

    Tile[] tiles;
    for (int i=0; i<lines.length; i+=1)
    {
        string header = lines[i++];
        int cursor = 0;
        if (tileHeader.parse(header, cursor))
        {
            Tile tile = new Tile();
            tile.ID = tileIndex.Get();
            while (lines[i].length > 0)
            {
                uint r = ParseBinary(lines[i++]);
                tile.Row ~= r;
            }
            tiles ~= tile;
        }
    }

    foreach(tile; tiles)
    {
        PrintTile(tile);
    }

}

/// 
void solve_20_2()
{
}
