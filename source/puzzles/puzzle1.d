module puzzles.puzzle1;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;


/// 
void solve_1_1()
{
    auto parser = new InputParser();

    int[] values;
    readFileLineByLine("input/input_1.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        int value;
        parser.parse(value);
        //writeln("  -> value=", value);
        values ~= value;
    });

    values.sort;
    auto sorted = assumeSorted(values);

    int target = 2020;

    findsum: for (int i=0; i<values.length; i++)
    {
        int n1 = sorted[i];
        int n2 = target - n1;
        if (sorted.contains(n2))
        {
            writeln("answer 1: ", n1 * n2);
            break findsum;
        }
    }    
}


/// 
void solve_1_2()
{
    auto parser = new InputParser();

    int[] values;
    readFileLineByLine("input/input_1.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        int value;
        parser.parse(value);
        //writeln("  -> value=", value);
        values ~= value;
    });

    values.sort;
    auto sorted = assumeSorted(values);

    int target = 2020;

    findsum: for (int i=0; i<values.length; i++)
    {
        int n1 = sorted[i];
        for (int j=i; j<values.length; j++)
        {
            int n2 = sorted[j];
            int n3 = target - n1 - n2;
            if (sorted.contains(n3))
            {
                writeln("answer 2: ", n1*n2*n3);
                break findsum;
            }
        }
    }    
}

