module puzzles.puzzle5;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

struct planeseat
{
    static int decode(string s)
    {
        int row = 0;
        int seat = 0;

        // FBFBBFF = 44
        // RLR = 5
        for (int i=0; i<s.length; ++i)
        {
            char c = s[i];
            if (c == 'F')
            {
                row = row << 1;
                row = (row | 0);
            }
            else if (c == 'B')
            {
                row = row << 1;
                row = (row | 1);
            }
            else if (c == 'L')
            {
                seat = seat << 1;
                seat = seat | 0;
            }
            else if (c == 'R')
            {
                seat = seat << 1;
                seat = seat | 1;
            }
        }

        // So, decoding FBFBBFFRLR reveals that it is the seat at row 44, column 5.
        // Every seat also has a unique seat ID: multiply the row by 8, then add the column.
        // In this example, the seat has ID 44 * 8 + 5 = 357.
        return row * 8 + seat;
    }
}


/// 
void solve_5_1()
{
    // instructions:
    // Start by considering the whole range, rows 0 through 127.
    // F means to take the lower half, keeping rows 0 through 63.
    // B means to take the upper half, keeping rows 32 through 63.
    // F means to take the lower half, keeping rows 32 through 47.
    // B means to take the upper half, keeping rows 40 through 47.
    // B keeps rows 44 through 47.
    // F keeps rows 44 through 45.
    // The final F keeps the lower of the two, row 44.

    planeseat testseat;
    int testID = testseat.decode("FBFBBFFRLR");
    writeln(testID);

    // BBFFBFBRLL
    int highest_seatID = 0;
    readFileLineByLine("input/input_5.text", (string line) {
        //writeln(line); 

        planeseat seat;
        int seatID = seat.decode(line);
        if (seatID > highest_seatID)
        {
            highest_seatID = seatID;
        }
    });

    writeln("1: highest seat ID: ", highest_seatID);
}

/// 
void solve_5_2()
{
    int[] seats;
    readFileLineByLine("input/input_5.text", (string line) {
        //writeln(line); 

        planeseat seat;
        int seatID = seat.decode(line);
        seats ~= seatID;
    });
    seats.sort();

    int missing_seat = 0;
    int previous_seat = seats[0];
    foreach(seat; seats)
    {
        if ((seat - previous_seat) > 1)
        {
            missing_seat = seat - 1;
            break;
        }
        previous_seat = seat;
    }

    writeln("2: missing seat ID: ", missing_seat);
}
