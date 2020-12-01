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
    readFileLineByLine("input/input_1_1.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        int value;
        parser.parse(value);
        //writeln("  -> value=", value);
        values ~= value;
    });

    int target = 2020;

    for (int i=0; i<values.length; i++)
    {
        for (int j=i+1; j<values.length; j++)
        {
            {
                if ((values[i] + values[j]) == target)
                {
                    writeln("answer 1: ", values[i] * values[j]);
                }
            }
        }
    }    

    for (int i=0; i<values.length; i++)
    {
        for (int j=i+1; j<values.length; j++)
        {
            for (int k=j+1; k<values.length; k++)
            {
                if ((values[i] + values[j] + values[k]) == target)
                {
                    writeln("answer 2: ", values[i] * values[j] * values[k]);
                }
            }
        }
    }

}

/// 
void solve_1_2()
{

}
