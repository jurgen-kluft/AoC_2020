module puzzles.puzzle2;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

struct password
{
    int min,max;
    char c;
    char[] pwd;
}

/// 
void solve_2_1()
{
    auto parser = new InputParser();
    password[] passwords;

    // 1-5 k: kkkkhkkkkkkkkkk
    readFileLineByLine("input/input_2.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        password p;
        parser.parse(p.min).consume("-").parse(p.max).parse(p.c).consume(":").parse(p.pwd);
        //writeln("  -> min=", min, " max=", max, " c:", c, " password=", pwd);
        passwords ~= p;
    });

    int valid_passwords = 0;
    foreach(password p; passwords)
    {
        int count = 0;
        foreach(char c; p.pwd)
        {
            if (c == p.c)
            {
                count++;
            }
        }
        if (count >= p.min && count <= p.max)
        {
            valid_passwords++;
        }
    }

    writeln("1: number of valid passwords: ", valid_passwords);
}

/// 
void solve_2_2()
{
    auto parser = new InputParser();

    password[] passwords;

    // 1-5 k: kkkkhkkkkkkkkkk
    readFileLineByLine("input/input_2.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        password p;
        parser.parse(p.min).consume("-").parse(p.max).parse(p.c).consume(":").parse(p.pwd);
        //writeln("  -> min=", min, " max=", max, " c:", c, " password=", pwd);
        passwords ~= p;
    });

    int valid_passwords = 0;
    foreach(password p; passwords)
    {
        if (p.pwd[p.min-1] == p.c && p.pwd[p.max-1] != p.c)
        {
            valid_passwords++;
        }
        else if (p.pwd[p.min-1] != p.c && p.pwd[p.max-1] == p.c)
        {
            valid_passwords++;
        }
    }

    writeln("2: number of valid passwords: ", valid_passwords);
}
