module puzzles.puzzle4;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

/// 
void solve_4_1()
{
    auto parser = new InputParser();

    string[] valid_keys = [ "byr","iyr","eyr","hgt","hcl","ecl","pid" ];

    int valid_passports = 0;
    int valid_fields = 0;
    readFileLineByLine("input/input_4.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        if (line == "")
        {
            if (valid_fields == valid_keys.length)
                valid_passports += 1;
            valid_fields = 0;
        }
        else
        {
            while (!parser.at_end())
            {
                parser.consume();
                KeyValue kv;
                kv.seperator = ':';
                parser.parse(kv);
                if (valid_keys.canFind(kv.key))
                {
                    valid_fields += 1;
                }
            }
        }
    });

    writeln("1: number of valid passports: ", valid_passports);
}

/// 
void solve_4_2()
{
    auto parser = new InputParser();

    string[] valid_keys = [ "byr","iyr","eyr","hgt","hcl","ecl","pid" ];

    int valid_passports = 0;
    int valid_fields = 0;
    readFileLineByLine("input/input_4.text", (string line) {
        //writeln(line); 
        parser.reset(line);
        if (line == "")
        {
            if (valid_fields == valid_keys.length)
                valid_passports += 1;
            valid_fields = 0;
        }
        else
        {
            while (!parser.at_end())
            {
                parser.consume();
                KeyValue kv;
                kv.seperator = ':';
                parser.parse(kv);
                if (valid_keys.canFind(kv.key))
                {
                    if (kv.key == "byr")
                    {
                        // byr (Birth Year) - four digits; at least 1920 and at most 2002.
                        if (kv.value.length == 4)
                        {
                            int byr = to!int(kv.value);
                            if (byr >= 1920 && byr <=2002)
                                valid_fields += 1;
                        }
                    }
                    else if (kv.key == "iyr")
                    {
                        // iyr (Issue Year) - four digits; at least 2010 and at most 2020.
                        if (kv.value.length == 4)
                        {
                            int byr = to!int(kv.value);
                            if (byr >= 2010 && byr <= 2020)
                                valid_fields += 1;
                        }
                    }
                    else if (kv.key == "eyr")
                    {
                        // eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
                        if (kv.value.length == 4)
                        {
                            int byr = to!int(kv.value);
                            if (byr >= 2020 && byr <= 2030)
                                valid_fields += 1;
                        }
                    }
                    else if (kv.key == "hgt")
                    {
                        // hgt (Height) - a number followed by either cm or in:
                        // If cm, the number must be at least 150 and at most 193.
                        // If in, the number must be at least 59 and at most 76.
                        if (endsWith(kv.value, "cm"))
                        {
                            string heightstr = kv.value.subRange(0, kv.value.length - 2).text;
                            int cm = to!int(heightstr);
                            if (cm >= 150 && cm <= 193)
                                valid_fields += 1;
                        }
                        else if (endsWith(kv.value, "in"))
                        {
                            string heightstr = kv.value.subRange(0, kv.value.length - 2).text;
                            int inches = to!int(heightstr);
                            if (inches >= 59 && inches <= 76)
                                valid_fields += 1;
                        }
                    }
                    else if (kv.key == "hcl")
                    {
                        // hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
                        if (startsWith(kv.value, "#") && kv.value.length == (1+6))
                        {
                            bool valid = true;
                            int i = 1;
                            while (i < 7 && ((kv.value[i]>='a' && kv.value[i] <='f') || (kv.value[i]>='0' && kv.value[i] <='9')))
                            {
                                i+=1;
                            }
                            if (i == 7)
                            {
                                valid_fields += 1;
                            }
                        }
                    }
                    else if (kv.key == "ecl")
                    {
                        // ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
                        string[] eye_colors = [ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" ];
                        if (eye_colors.canFind(kv.value))
                            valid_fields += 1;
                    }
                    else if (kv.key == "pid")
                    {
                        // pid (Passport ID) - a nine-digit number, including leading zeroes.
                        size_t n = eatIntegerChars(kv.value, 0);
                        if (n == 9)
                        {
                            valid_fields += 1;
                        }
                    }
                    else if (kv.key == "cid")
                    {
                        // cid (Country ID) - ignored, missing or not.    
                    }

                }
            }
        }
    });

    writeln("2: number of valid passports: ", valid_passports);
}
