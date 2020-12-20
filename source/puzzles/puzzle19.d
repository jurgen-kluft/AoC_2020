module puzzles.puzzle19;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism : parallel;
import core.stdc.string : strlen;

import utilities.inputparser;
import parser = utilities.parser2;

class operation_t
{
    bool match(char c, rule_t[] ops)
    {
        return false;
    }
}

class match_t : operation_t
{
    char m_str;
    this(char str)
    {
        m_str = str;
    }

    override bool match(char c, rule_t[] ops)
    {
        return false;
    }
}

class ref_t : operation_t
{
    int m_index;
    this(int index)
    {
        m_index = index;
    }

    override bool match(char c, rule_t[] ops)
    {
        return false;
    }
}

class and_t : operation_t
{
    operation_t m_a;
    operation_t m_b;
    this(operation_t a, operation_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool match(char c, rule_t[] ops)
    {
        return false;
    }
}

class or_t : operation_t
{
    operation_t m_a;
    operation_t m_b;
    this(operation_t a, operation_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool match(char c, rule_t[] ops)
    {
        return false;
    }
}

class rule_t
{
    operation_t m_op;

    this(char c)
    {
        m_op = new match_t(c);
        writeln("== ", c);
    }

    this(int r11, int r12)
    {
        m_op = new and_t(new ref_t(r11), new ref_t(r12));
        writeln(r11," & ", r12);
    }

    this(int r11, int r12, int r21, int r22)
    {
        m_op = new or_t(new and_t(new ref_t(r11), new ref_t(r12)), new and_t(new ref_t(r21), new ref_t(r22)));
        writeln("(", r11," & ", r12, ") | (", r21," & ", r22, ")");
    }

    bool match(char c, rule_t[] ops)
    {
        return m_op.match(c, ops);
    }
}

const int PARSE_RULES = 1;
const int PARSE_MESSAGES = 2;
/// 
void solve_19_1()
{
    // Examples
    // 0: 8 11
    // 45: 46 52 | 9 72

    int idx,r11,r12,r21,r22,rcount;
    parser.seq_t seq_rule1 = new parser.seq_t(
        new parser.integer_t(&idx, &rcount),
        new parser.zeroOrMore_t(new parser.whitespace_t()),
        new parser.is_t(':'),
        new parser.seq_t(
            new parser.oneOrMore_t(new parser.whitespace_t()),
            new parser.integer_t(&r11, &rcount),
            new parser.oneOrMore_t(new parser.whitespace_t()),
            new parser.integer_t(&r12, &rcount),
            new parser.zeroOrMore_t(new parser.whitespace_t()),
            new parser.or_t(
                new parser.seq_t(
                    new parser.is_t('|'),
                    new parser.oneOrMore_t(new parser.whitespace_t()),
                    new parser.integer_t(&r21, &rcount),
                    new parser.oneOrMore_t(new parser.whitespace_t()),
                    new parser.integer_t(&r22, &rcount),
                    new parser.zeroOrMore_t(new parser.whitespace_t()),
                    new parser.eol_t()
                ),
                new parser.eol_t()
            )
        )
    );

    // Example
    // 72: "b"
    string r1c;
    parser.seq_t seq_rule2 = new parser.seq_t(
        new parser.integer_t(&idx,&rcount),
        new parser.is_t(':'),
        new parser.seq_t(
            new parser.oneOrMore_t(new parser.whitespace_t()),
            new parser.is_t('"'),
            new parser.string_t(&r1c, &rcount),
            new parser.is_t('"'),
            new parser.zeroOrMore_t(new parser.whitespace_t()),
            new parser.eol_t()
        )
    );


    rule_t[] rules;
    string[] msgs;
    {
        int state = PARSE_RULES;
        auto parser = new InputParser();
        readFileLineByLine("input/input_19.text", (string line) {
            parser.reset(line);
            if (line.length == 0)
            {
                state = PARSE_MESSAGES;
                return;
            }

            if (state == PARSE_RULES)
            {
                int cursor = 0;
                rcount = 0;
                if (seq_rule2.parse(line, cursor))
                {
                    rule_t rule = new rule_t(r1c[0]);
                    rules ~= rule;
                }
                else
                {
                    rcount = 0;
                    if (seq_rule1.parse(line, cursor))
                    {
                        if (rcount == 3)
                        {
                            rule_t rule = new rule_t(r11,r12);
                            rules ~= rule;
                        }
                        else if (rcount == 5)
                        {
                            rule_t rule = new rule_t(r11,r12,r21,r22);
                            rules ~= rule;
                        }
                    }
                }
            }
            else if (state == PARSE_MESSAGES)
            {
                msgs ~= line;
            }
        });
    }

    int count_of_messages_that_match_the_rules = 0;
    foreach(msg; msgs)
    {
        int matches = 0;
        foreach(c; msg)
        {
            if (rules[0].match(c, rules))
            {
                matches += 1;
            }
            else
            {
                break;
            }
        }

        if (matches == msg.length)
        {
            count_of_messages_that_match_the_rules += 1;
        }
    }

    writeln("1: number of messages that match the rules = ",count_of_messages_that_match_the_rules);
}

/// 
void solve_19_2()
{
}
