module puzzles.puzzle12;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.stdc.string : strlen;
import utilities.inputparser;

const int NORTH = 0;
const int EAST = 1;
const int SOUTH = 2;
const int WEST = 3;
const int UKNOWN = -1;
const int TURN_LEFT = 4;
const int TURN_RIGHT = 5;
const int FORWARD = 6;

struct change
{
    int compass;
    int amount;
};

struct boogie
{
    int dir;
    int x;
    int y;
};

change parse(string str)
{
    change cc;
    if (str[0] == 'N')
    {
        cc.compass = NORTH;
    }
    else if (str[0] == 'S')
    {
        cc.compass = SOUTH;
    }
    else if (str[0] == 'E')
    {
        cc.compass = EAST;
    }
    else if (str[0] == 'W')
    {
        cc.compass = WEST;
    }
    else if (str[0] == 'L')
    {
        cc.compass = TURN_LEFT;
    }
    else if (str[0] == 'R')
    {
        cc.compass = TURN_RIGHT;
    }
    else if (str[0] == 'F')
    {
        cc.compass = FORWARD;
    }

    int i = 1;
    int number = 0;
    while (i < str.length)
    {
        if (str[i] >= '0' && str[i] <= '9')
            number = (number * 10) + (str[i] - '0');
        i += 1;
    }
    cc.amount = number;

    return cc;
}

int normalizeAngle(int dir)
{
    while (dir < 0)
        dir += 360;
    while (dir >= 360)
        dir -= 360;
    return dir;
}

int angleToCompassDir(int dir)
{
    if (dir == 0)
        return NORTH;
    else if (dir == 90)
        return EAST;
    else if (dir == 180)
        return SOUTH;
    else if (dir == 270)
        return WEST;

    return UKNOWN;
}

boogie move(boogie b, int compass, int amount)
{
    if (compass == NORTH)
    {
        b.y -= amount;
    }
    else if (compass == SOUTH)
    {
        b.y += amount;
    }
    else if (compass == WEST)
    {
        b.x -= amount;
    }
    else if (compass == EAST)
    {
        b.x += amount;
    }
    else
    {
        writeln("Unknown compass direction for angle = ", b.dir);
    }
    return b;
}

boogie  execute(change c, boogie b)
{
    // Action N means to move north by the given value.
    // Action S means to move south by the given value.
    // Action E means to move east by the given value.
    // Action W means to move west by the given value.
    // Action L means to turn left the given number of degrees.
    // Action R means to turn right the given number of degrees.
    // Action F means to move forward by the given value in the direction the ship is currently facing.
    if (c.compass == FORWARD)
    {
        change cc;
        b.dir = normalizeAngle(b.dir);
        int compass = angleToCompassDir(b.dir);
        int amount = c.amount;
        b = move(b, compass, amount);
    }
    else if (c.compass == TURN_LEFT)
    {
        b.dir -= c.amount;
    }
    else if (c.compass == TURN_RIGHT)
    {
        b.dir += c.amount;
    }
    else
    {
        int amount = c.amount;
        b = move(b, c.compass, amount);
    }
    return b;
}


/// 
void solve_12_1()
{
    change[] instructions;

    auto parser = new InputParser();
    readFileLineByLine("input/input_12.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        change c = parse(line);
        instructions ~= c;
    });
    //writeln(instructions);

    boogie b;
    // EAST = 90, NORTH = 0, WEST = 270, SOUTH = 180
    b.dir = 90; 
    b.x = 0;
    b.y = 0;

    foreach (cc; instructions)
    {
        b = execute(cc, b);
    }

    writeln("1: Manhattan distance = ", abs(b.x) + abs(b.y));
}

/// 
void solve_12_2()
{
    change[] instructions;

    auto parser = new InputParser();
    readFileLineByLine("input/input_12.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        change c = parse(line);
        instructions ~= c;
    });
    //writeln(instructions);

    boogie ship;
    boogie waypoint;

    // ANGLE => EAST = 90, NORTH = 0, WEST = 270, SOUTH = 180
    // MOVE => NORTH = -1, SOUTH = +1, WEST = -1, EAST = +1
    ship.dir = 0; 
    ship.x = 0;
    ship.y = 0;

    waypoint.dir = 0;       // This acts as rotation amount
    waypoint.x = 10;
    waypoint.y = -1;

    foreach (cc; instructions)
    {
        if (cc.compass == TURN_LEFT)
        {
            waypoint.dir -= cc.amount;
        }
        else if (cc.compass == TURN_RIGHT)
        {
            waypoint.dir += cc.amount;
        }
        else
        {
            // Rotate the waypoint
            waypoint.dir = normalizeAngle(waypoint.dir);
            int waypointx = waypoint.x;
            int waypointy = waypoint.y;
            if (waypoint.dir == 270)    // -90
            {
                waypoint.x = waypointy;
                waypoint.y = -waypointx;
            }
            else if (waypoint.dir == 90)
            {
                waypoint.x = -waypointy;
                waypoint.y = waypointx;
            }
            else if (waypoint.dir == 180)
            {
                waypoint.x = -waypointx;
                waypoint.y = -waypointy;
            }
            waypoint.dir = 0;   // Reset rotation

            if (cc.compass == FORWARD)
            {
                ship.x += (cc.amount * waypoint.x);
                ship.y += (cc.amount * waypoint.y);
            }
            else    // NORTH, SOUTH, EAST and WEST move the waypoint
            {
                int amount = cc.amount;
                waypoint = move(waypoint, cc.compass, amount);
            }
        }
    }

    writeln("2: Manhattan distance = ", abs(ship.x) + abs(ship.y));
}