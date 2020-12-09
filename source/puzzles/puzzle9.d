module puzzles.puzzle9;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

alias u64 = ulong;

bool findSum(u64[] values, u64 target)
{
    auto sorted = assumeSorted(values);
    int n = cast(int)values.length - 1;
    for (int i = 0; i < n; i++)
    {
        if (values[i] >= target)
            return false;

        u64 x = target - values[i];
        if (sorted.contains(x))
        {
            return true;
        }
    }
    return false;
}

/// 
void solve_9_1()
{
    u64[] values;

    auto parser = new InputParser();
    readFileLineByLine("input/input_9.text", (string line) {
        parser.reset(line);

        u64 value;
        parser.parse(value);
        values ~= value;
    });

    u64[] sorted;
    int preamble = 25;

    for (int c = preamble; c < values.length; c++)
    {
        sorted.length = 0;
        int i = c - preamble;
        while(sorted.length != 25)
        {
            sorted ~= values[i];
            i += 1;
        }
        sort(sorted);

        if (!findSum(sorted, values[c]))
        {
            //writeln(sorted, ":", sorted.length, " for ", values[c], ":", c);
            writeln("1: ", values[c]);
            break;
        }
    }
}

/// 
void solve_9_2()
{
    u64[] values;

    auto parser = new InputParser();
    readFileLineByLine("input/input_9.text", (string line) {
        parser.reset(line);

        u64 value;
        parser.parse(value);
        values ~= value;
    });

    u64[] sorted;
    int preamble = 25;

    for (int c = preamble; c < values.length; c++)
    {
        sorted.length = 0;
        int i = c - preamble;
        while(sorted.length != 25)
        {
            sorted ~= values[i];
            i += 1;
        }
        sort(sorted);

        if (!findSum(sorted, values[c]))
        {
            u64 invalid_number = values[c];

            int n = c - 2;
            int m = c - 1;
            u64 smallest;
            u64 largest;
            FINDCONTINUESSET: for (int l = 0 ; l < n; l++)
            {
                u64 sum = values[l];
                smallest = values[l];
                largest = values[l];
                for (int h = l + 1; h < m; h++)
                {
                    largest = max(largest, values[h]);
                    smallest = min(smallest, values[h]);

                    sum += values[h];
                    if (sum == invalid_number)
                        break FINDCONTINUESSET;
                    if (sum > invalid_number)
                        break;
                }
            }
            u64 weakness = smallest + largest;

            writeln("2: ", weakness);
            break;
        }
    }
}
