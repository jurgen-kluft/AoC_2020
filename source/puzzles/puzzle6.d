module puzzles.puzzle6;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

/// 
void solve_6_1()
{
    bool[26] answers;
    for (int i=0; i<answers.length; ++i)
        answers[i] = false;

    int sum = 0;
    readFileLineByLine("input/input_6.text", (string line) {
        //writeln(line); 
        if (line == "")
        {
            int count = 0;
            for (int i=0; i<answers.length; ++i)
                count += answers[i] ? 1 : 0;

            for (int i=0; i<answers.length; ++i)
                answers[i] = false;
            sum += count;
        }
        else
        {
            foreach(c; line)
            {
                int question = (c - 'a');
                answers[question] = true;
            }
        }
    });

    writeln("1: ", sum);

}

/// 
void solve_6_2()
{
    int persons = 0;
    int[26] answers;
    for (int i=0; i<answers.length; ++i)
        answers[i] = 0;

    int sum = 0;
    readFileLineByLine("input/input_6.text", (string line) {
        //writeln(line); 
        if (line == "")
        {
            int count = 0;
            for (int i=0; i<answers.length; ++i)
                count += (answers[i]==persons) ? 1 : 0;

            for (int i=0; i<answers.length; ++i)
                answers[i] = 0;
            persons = 0;
            sum += count;
        }
        else
        {
            foreach(c; line)
            {
                int question = (c - 'a');
                answers[question] += 1;
            }
            persons += 1;
        }
    });

    writeln("2: ", sum);
}
