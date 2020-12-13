module puzzles.puzzle13;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism: parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

alias u64 = ulong;

/// 
void solve_13_1()
{
    ulong earliestdeparture = 1002578;

    u64[] busIDs;

    auto parser = new InputParser();

    readFileLineByLine("input/input_13.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        if (line[0] != 'x')
        {
            int i = 0;
            ulong busID = 0;
            while (i < line.length)
            {
                if (line[i] >= '0' && line[i] <= '9')
                    busID = (busID * 10) + (line[i] - '0');
                i += 1;
            }
            busIDs ~= busID;
        }
    });
    writeln(busIDs);

    u64 earliestBusID = u64.max;
    u64 earliestBusMinutesToWait = u64.max;
    foreach(busID; busIDs)
    {
        u64 rounds = earliestdeparture / busID;
        u64 minutesToWait = ((rounds + 1) * busID) - earliestdeparture;
        if (minutesToWait < earliestBusMinutesToWait)
        {
            earliestBusMinutesToWait = minutesToWait;
            earliestBusID = busID;
        }
    }
    writeln("1: Earliest Bus ID = ", earliestBusID);
    writeln("1: Earliest Bus MinutesToWait = ", earliestBusMinutesToWait);
    writeln("1: Earliest BusID * MinutesToWait = ", earliestBusID * earliestBusMinutesToWait);
}

struct Bus
{
    u64 ID;
    int Minute;
};

struct MultiCoreBusSolver
{
    Bus[] busses;
    shared(ulong) finished;

    u64 Solve(int worker, int N)
    {
        u64 i = 0;
        u64 t = (751 * 19) - 19 + (worker * (751 * 19));
        while (true)
        {
            int correct_departures = 0;
            foreach(bus; busses)
            {
                u64 departure_time = t + bus.Minute;
                u64 rounds = departure_time / bus.ID;
                if ((rounds * bus.ID) != departure_time)
                    break;
                correct_departures += 1;
            }

            if ((i & 0xfffffff) == 0)
            {
                if (finished.atomicLoad() == 1)
                    return 0;
                i = 0;
                writeln("2: Current time = ", t);
            }

            if (correct_departures == cast(int)busses.length)
            {
                finished.atomicOp!"+="(1);
                writeln("2: Earliest Time ", t);
                return t;
            }

            i += 1;
            t += (751 * 19) * N;
        }        
    }

};

/// 
void solve_13_2()
{
    MultiCoreBusSolver solver;

    auto parser = new InputParser();
    int minute = 0;
    readFileLineByLine("input/input_13.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        if (line[0] != 'x')
        {
            Bus b;
            b.Minute = minute;

            int i = 0;
            ulong busID = 0;
            while (i < line.length)
            {
                if (line[i] >= '0' && line[i] <= '9')
                    busID = (busID * 10) + (line[i] - '0');
                i += 1;
            }
            b.ID = busID;
            solver.busses ~= b;
        }
        minute += 1;
    });
    writeln(solver.busses);

    int numthreads = 4;
    u64[] time;
    time.length = numthreads;

    auto lanes = std.range.iota(0, numthreads);
    foreach(thrd; parallel(lanes))
    {
        time[thrd] = solver.Solve(thrd, numthreads);
    }
}

