module puzzles.puzzle10;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

alias u64 = ulong;


/// 
void solve_10_1()
{
    u64[] values;

    auto parser = new InputParser();
    readFileLineByLine("input/input_10.text", (string line) {
        parser.reset(line);
        u64 value;
        parser.parse(value);
        values ~= value;
    });

    sort(values);
    auto sorted = assumeSorted(values);
    //writeln(sorted);

    int i = 0;
    int[] num_differences = [0,0,0];
    while (i < (sorted.length - 1))
    {
        int n = i + 1;
        if ((sorted[n] - sorted[i]) == 1)
        {
            i++;
            num_differences[0] += 1;
        }
        else if ((sorted[n] - sorted[i]) == 2)
        {
            i++;
            num_differences[1] += 1;
        }
        else if ((sorted[n] - sorted[i]) == 3)
        {
            i++;
            num_differences[2] += 1;
        }
    }
    num_differences[2] += 1;

    writeln("1: 1 diff = ", num_differences[0]);
    writeln("1: 2 diff = ", num_differences[1]);
    writeln("1: 3 diff = ", num_differences[2]);
    writeln();
    writeln("1: ", num_differences[0] * num_differences[2]);
}

/// 
void solve_10_2()
{
    int[] values;
    auto parser = new InputParser();
    readFileLineByLine("input/input_10.text", (string line) {
        parser.reset(line);
        int value;
        parser.parse(value);
        values ~= value;
    });

    sort(values);
    values ~= values.back + 3;
    auto sorted = assumeSorted(values);

    int largest = sorted.back;
    int[] continues;
    
    for (int i=0, j=0; i<=largest; i+=1)
    {
        if (sorted[j] == i)
        {
            continues ~= i;
            j += 1;
        }
        else
        {
            continues ~= -i;
        }
    }


    int[] jmp;
    jmp.length = continues.length;
    long[] perms;
    perms.length = continues.length;
    for (int i=0; i<(continues.length - 1); i += 1)
    {
        if (continues[i] < 0)
        {
            jmp[i] = 0;
            perms[i] = 0;
        }
        else
        {
            int j = 1;
            while (continues[i + j] < 0)
            {
                jmp[i+j] = 0;
                perms[i+j] = 0;
                j += 1;
            }
            jmp[i] = j;
            perms[i] = 0;
        }
    }
    perms.back = 1;
    jmp.back = 0;

    writeln();
    for (int i=0; i<continues.length; i += 1)
    {
        //writeln(continues[i], " :j= ", jmp[i], " :p= ", perms[i]);
    }
    writeln();

    for (int i = cast(int)continues.length - 1; i >= 0; /* conditionally decremented */)
    {
        if (continues[i] < 0)
        {
            i -= 1;
            continue;
        }

        if (jmp[i] == 1)
        {
            perms[i] += perms[i + 1];

            // Can we do a jump of 2, or otherwise 3 ?
            if (continues[i + 2] >= 0)
            {
                jmp[i] = 2;
            }
            else if (continues[i + 3] >= 0)
            {
                jmp[i] = 3;
            }
            else
            {
                jmp[i] = 0;
            }
        }
        else if (jmp[i] == 2)
        {
            perms[i] += perms[i + 2];

            // Can we do a jump of 3 ?
            if (continues[i + 3] >= 0)
            {
                jmp[i] = 3;
            }
            else
            {
                jmp[i] = 0;
            }
        }
        else if (jmp[i] == 3)
        {
            perms[i] += perms[i + 3];
            i -= 1;
        }
        else
        {
            i -= 1;
        }
    }

    writeln();
    writeln(perms);
    long num_combinations = perms[0];

    writeln("2: ", num_combinations);
}
