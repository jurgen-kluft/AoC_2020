module puzzles.puzzle15;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism: parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

const int OLD = 1;
const int RECENT = 0;
struct age_t
{

    int[2] turn_history;

    void init()
    {
        turn_history[0] = -1;
        turn_history[1] = -1;
    }

    bool is_first_time_seen()
    {
        return turn_history[OLD] == -1;
    }

    void seen_at(int turn)
    {
        turn_history[OLD] = turn_history[RECENT];
        turn_history[RECENT] = turn;
    }

    int age()
    {
        return turn_history[RECENT] - turn_history[OLD];
    }
};

/// 
void solve_15_1()
{
    auto parser = new InputParser();

    int target = 2020;
    age_t[] ages;
    ages.length = target + 1;
    for (int i=0; i<=target; i++)
    {
        ages[i].init();
    }

    int turn = 0;
    int last = 0;
    readFileLineByLine("input/input_15.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        int number;
        parser.parse(number);
        ages[number].seen_at(turn);
        last = number;

        turn += 1;
    });

    while (turn < target)
    {
        if (ages[last].is_first_time_seen())
        {
            // First time spoken
            last = 0;
            ages[last].seen_at(turn);
        }
        else
        {
            last = ages[last].age();
            ages[last].seen_at(turn);
        }

        turn += 1;
    }

    writeln("1: the ", target," number spoken = ", last);
}

/// 
void solve_15_2()
{
    auto parser = new InputParser();

    int target = 30000000;
    age_t[] ages;
    ages.length = target + 1;
    for (int i=0; i<=target; i++)
    {
        ages[i].init();
    }

    int turn = 0;
    int last = 0;
    readFileLineByLine("input/input_15.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        int number;
        parser.parse(number);
        ages[number].seen_at(turn);
        last = number;

        turn += 1;
    });

    while (turn < target)
    {
        if (ages[last].is_first_time_seen())
        {
            // First time spoken
            last = 0;
            ages[last].seen_at(turn);
        }
        else
        {
            last = ages[last].age();
            ages[last].seen_at(turn);
        }

        turn += 1;
    }

    writeln("2: the ", target," number spoken = ", last);
}
