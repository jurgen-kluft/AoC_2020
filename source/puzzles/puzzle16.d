module puzzles.puzzle16;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism: parallel;
import core.stdc.string : strlen;
import utilities.inputparser;


struct range_t
{
    int m_min;
    int m_max;

    bool is_inside(int val)
    {
        return (val>=m_min && val<=m_max);
    }
};

struct field_t
{
    int col;
    byte[] possible_columns;
    string name;
    range_t[2] ranges;

    int get_single_possible_column()
    {
        int c = -1;
        foreach(i, e; possible_columns)
        {
            if (e == 0)
                continue;
            if (c != -1)
                return -1;
            c = cast(int)i;
        }
        return c;
    }

    bool is_inside(int val)
    {
        foreach(range; ranges)
        {
            if (range.is_inside(val))
                return true;
        }
        return false;
    }
};

struct ticket_t
{
    int[] numbers;
}

const int KEY_INFO = 1;
const int YOUR_TICKET = 3;
const int NEARBY_TICKETS = 2;

/// 
void solve_16_1()
{
    auto parser = new InputParser();

    field_t[] fields;
    ticket_t[] tickets;

    int state = KEY_INFO;
    readFileLineByLine("input/input_16.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        if (startsWith(line, "your"))
        {
            // Ignore
            state = YOUR_TICKET;
        }
        else if (startsWith(line, "nearby tickets"))
        {
            state = NEARBY_TICKETS;
        }
        else
        {
            if (state == YOUR_TICKET || state == NEARBY_TICKETS)
            {
                ticket_t t;
                auto parts = line.split(",");
                foreach(p; parts)
                {
                    int num = parse!int(p);
                    t.numbers ~= num;
                }

                // Ignore your ticket
                if (state == NEARBY_TICKETS)
                {
                    tickets ~= t;
                }
            }

            if (state == KEY_INFO)
            {
                field_t f;

                string key;
                int min1,max1,min2,max2;
                if (line.formattedRead!"%s: %d-%d or %d-%d"(key,min1,max1,min2,max2) > 0)
                {
                    f.name = key;

                    range_t r;
                    r.m_min = min1;
                    r.m_max = max1;
                    f.ranges[0] = r;

                    r.m_min = min2;
                    r.m_max = max2;
                    f.ranges[1] = r;
                }

                fields ~= f;
            }
        }
    });

    int error_rate = 0;
    int[] valid_fields;
    valid_fields.length = fields.length;
    foreach(ticket; tickets)
    {
        foreach(number; ticket.numbers)
        {
            // Does number fall into one of the ranges ?
            bool valid = false;
            foreach(fi, field; fields)
            {  
                if (field.is_inside(number))
                {
                    valid = true;
                }
            }
            if (!valid)
            {
                error_rate += number;
            }
        }
    }
    writeln("1: error rate = ", error_rate);
}

/// 
void solve_16_2()
{
    auto parser = new InputParser();

    field_t[] fields;
    ticket_t[] tickets;

    int[] departure_fields;

    ticket_t my_ticket;

    int state = KEY_INFO;
    readFileLineByLine("input/input_16.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        if (startsWith(line, "your"))
        {
            // Ignore
            state = YOUR_TICKET;
        }
        else if (startsWith(line, "nearby tickets"))
        {
            state = NEARBY_TICKETS;
        }
        else
        {
            if (state == YOUR_TICKET || state == NEARBY_TICKETS)
            {
                ticket_t t;
                auto parts = line.split(",");
                foreach(p; parts)
                {
                    int num = parse!int(p);
                    t.numbers ~= num;
                }

                // Ignore your ticket
                if (state == NEARBY_TICKETS)
                {
                    tickets ~= t;
                }
                else
                {
                    my_ticket = t;
                }
            }

            if (state == KEY_INFO)
            {
                field_t f;

                string key;
                int min1,max1,min2,max2;
                if (line.formattedRead!"%s: %d-%d or %d-%d"(key,min1,max1,min2,max2) > 0)
                {
                    f.name = key;
                    range_t r;
                    r.m_min = min1;
                    r.m_max = max1;
                    f.ranges[0] = r;
                    r.m_min = min2;
                    r.m_max = max2;
                    f.ranges[1] = r;
                }

                if (startsWith(key, "departure"))
                {
                    departure_fields ~= cast(int)fields.length;
                }

                fields ~= f;
            }
        }
    });

    ticket_t[] valid_tickets;

    int error_rate = 0;
    int[] valid_fields;
    valid_fields.length = fields.length;
    foreach(ticket; tickets)
    {
        bool valid_ticket = true;
        foreach(number; ticket.numbers)
        {
            // Does number fall into one of the ranges ?
            bool valid = false;
            foreach(fi, field; fields)
            {  
                foreach(range; field.ranges)
                {
                    if (range.is_inside(number))
                    {
                        valid = true;
                    }
                }
            }
            valid_ticket = valid_ticket & valid;
        }
        if (valid_ticket)
        {
            valid_tickets ~= ticket;
        }
    }

    writeln("2: number of total tickets = ", tickets.length);
    writeln("2: number of valid tickets = ", valid_tickets.length);
    writeln("2: my ticket = ", my_ticket);
    writeln("2: departure fields = ", departure_fields);

    int numcolumns = cast(int)my_ticket.numbers.length;

    foreach(fi, field; fields)
    {
        fields[fi].col = -1;
        fields[fi].possible_columns.length = numcolumns;
        fill(fields[fi].possible_columns, cast(byte)0);
    }

    foreach(fi, field; fields)
    {
        for (int c=0; c<fields.length; ++c)
        {
            bool valid_column = true;
            foreach(ticket; valid_tickets)
            {
                if (!field.is_inside(ticket.numbers[c]))
                {
                    valid_column = false;
                    break;
                }
            }
            if (valid_column)
            {
                fields[fi].possible_columns[c] = 1;
            }
        }
    }

    // REDUCE, for all fields find their only possible column
    int changed = 1;
    while (changed != 0)
    {
        changed = 0;
        foreach(fi1, field1; fields)
        {
            int col = field1.get_single_possible_column();
            if (col != -1)
            {
                if (fields[fi1].col == -1)
                {                
                    writeln("2: field(", fi1, ") ", field1.name, " is at column ", col);
                    fields[fi1].col = col;
                }

                // set this one false for all other fields
                foreach(fi2, field2; fields)
                {
                    if (fi2 == fi1)
                        continue;
                    changed += fields[fi2].possible_columns[col];
                    fields[fi2].possible_columns[col] = 0;
                }
            }
        }
    }

    long answer = 1;
    foreach(fi, field; fields)
    {
        if (fields[fi].col == -1)
        {
            writeln("2: still have an unresolved field ", field.name);
            answer = 0;
        }
        
    }

    if (answer == 1)
    {
        foreach(dfi; departure_fields)
        {
            int col = fields[dfi].col;
            answer = answer * my_ticket.numbers[col];
        }
        writeln("2: answer = ", answer);
    }


}
