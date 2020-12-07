module puzzles.puzzle7;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;


struct bag
{
    int index;
    int[] parents;
    int[] children;
}

int indexOf(string[] array, string w)
{
    for (int i=0; i<array.length; ++i)
    {
        if (array[i] == w)
            return i;
    }
    return -1;
}

/// 
void solve_7_1()
{
    string[] bag_names;
    bag[] bags;

    auto parser = new InputParser();
    readFileLineByLine("input/input_7.text", (string line) {
        parser.reset(line);

        bag parent;
        string bagname_first;
        string bagname_last;
        string bagname;

        parser.readWord(bagname_first);
        parser.readWord(bagname_last);
        bagname = (bagname_first ~ bagname_last);

        int parentindex = indexOf(bag_names, bagname);
        if (parentindex < 0)
        {
            parentindex = cast(int)bag_names.length;
            bag_names ~= bagname;
            bags ~= [];
            bags[parentindex].index = parentindex;
        }

        parser.consume("bags");
        parser.consume("bag");
        parser.consume("contain");

        char separator = ',';
        while (separator == ',' && !parser.at_end())
        {
            int amount;
            parser.parse(amount);

            parser.readWord(bagname_first);
            parser.readWord(bagname_last);
            
            bag child;
            bagname = (bagname_first ~ bagname_last);
            int childindex = indexOf(bag_names, bagname);
            if (childindex < 0)
            {
                childindex = cast(int)bag_names.length;
                bag_names ~= bagname;
                bags ~= [];
                bags[childindex].index = childindex;
            }

            bags[childindex].parents ~= parentindex;
            bags[parentindex].children ~= childindex;

            parser.read(separator);
        }

    });

}

/// 
void solve_7_2()
{

}
