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
    bool match(string msg, int cursor, rule_t[int] ops, ref bool matchedFullMessage)
    {
        //assert(false);
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

    override bool match(string msg, int cursor, rule_t[int] ops, ref bool matchedFullMessage)
    {
        if (m_str == msg[cursor])
        {
            if (cursor == (msg.length - 1))
                matchedFullMessage = true;
            return true;
        }
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

    override bool match(string msg, int cursor, rule_t[int] ops, ref bool matchedFullMessage)
    {
        rule_t r = ops[m_index];
        return r.match(msg, cursor, ops,matchedFullMessage);
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

    override bool match(string msg, int cursor, rule_t[int] ops, ref bool matchedFullMessage)
    {
        const bool a = m_a.match(msg, cursor, ops,matchedFullMessage);
        if (a)
        {
            const bool b = m_b.match(msg, cursor + 1, ops,matchedFullMessage);
            return b;
        }
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

    override bool match(string msg, int cursor, rule_t[int] ops, ref bool matchedFullMessage)
    {
        const bool a = m_a.match(msg, cursor, ops,matchedFullMessage);
        if (!a)
        {
            const bool b = m_b.match(msg, cursor, ops,matchedFullMessage);
            return b;
        }
        return true;
    }
}

const byte TYPE_REF = 1;
const byte TYPE_OR = 2;
const byte TYPE_AND = 3;
const byte TYPE_OR_AND_AND = 4;

class rule_t
{
    int m_index;
    operation_t m_op;

    this(int index, char c)
    {
        m_index = index;
        m_op = new match_t(c);
        //writeln(m_index,": == ", c);
    }

    this(int index, byte type, int r11, int r12, int r21, int r22)
    {
        m_index = index;
        if (type == TYPE_REF)
        {
            m_op = new ref_t(r11);
            //writeln(m_index,": => ", r11);
        }
        else if (type == TYPE_OR)
        {
            m_op = new or_t(new ref_t(r11), new ref_t(r12));
            //writeln(m_index,": ", r11, " OR ", r12);
        }
        else if (type == TYPE_AND)
        {
            m_op = new and_t(new ref_t(r11), new ref_t(r12));
            //writeln(m_index,": ", r11, " AND ", r12);
        }
        else if (type == TYPE_OR_AND_AND)
        {
            m_op = new or_t(new and_t(new ref_t(r11), new ref_t(r12)), new and_t(new ref_t(r21), new ref_t(r22)));
            //writeln(m_index,": (", r11," AND ", r12, ") OR (", r21," AND ", r22, ")");
        }
    }

    bool match(string msg, int cursor, rule_t[int] ops, ref bool matchedFullMessage)
    {
        return m_op.match(msg, cursor, ops,matchedFullMessage);
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
    // 8: 42

    int idx,r11,r12,r21,r22,rcount;
    parser.seq_t seq_rule1 = new parser.seq_t(
        new parser.integer_t(&idx, &rcount),
        new parser.zeroOrMore_t(new parser.whitespace_t()),
        new parser.is_t(':'),
        new parser.seq_t(
            new parser.oneOrMore_t(new parser.whitespace_t()),
            new parser.integer_t(&r11, &rcount),
            new parser.zeroOrMore_t(new parser.whitespace_t()),
            new parser.or_t(
                new parser.eol_t(),
                new parser.seq_t(
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
            )
        )
    );

    // 113: 72 | 52
    parser.seq_t seq_rule2 = new parser.seq_t(
        new parser.integer_t(&idx, &rcount),
        new parser.zeroOrMore_t(new parser.whitespace_t()),
        new parser.is_t(':'),
        new parser.seq_t(
            new parser.oneOrMore_t(new parser.whitespace_t()),
            new parser.integer_t(&r11, &rcount),
            new parser.zeroOrMore_t(new parser.whitespace_t()),
            new parser.is_t('|'),
            new parser.oneOrMore_t(new parser.whitespace_t()),
            new parser.integer_t(&r12, &rcount),
            new parser.zeroOrMore_t(new parser.whitespace_t()),
            new parser.eol_t()
        )
    );

    // Example
    // 72: "b"
    string r1c;
    parser.seq_t seq_rule5 = new parser.seq_t(
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

    rule_t[int] rules;
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
                if (seq_rule5.parse(line, cursor))
                {
                    rules[idx] = new rule_t(idx, r1c[0]);
                }
                else
                {
                    rcount = 0;
                    if (seq_rule2.parse(line, cursor))
                    {
                        rules[idx] = new rule_t(idx, TYPE_OR, r11,r12,r21,r22);
                    }
                    else
                    {
                        rcount = 0;
                        if (seq_rule1.parse(line, cursor))
                        {
                            if (rcount == 2)
                            {
                                rules[idx] = new rule_t(idx, TYPE_REF, r11,r12,r21,r22);
                            }
                            else if (rcount == 3)
                            {
                                rules[idx] = new rule_t(idx, TYPE_AND, r11,r12,r21,r22);
                            }
                            else if (rcount == 5)
                            {
                                rules[idx] = new rule_t(idx, TYPE_OR_AND_AND, r11,r12,r21,r22);
                            }
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
        int cursor = 0;
        bool matchedFullMessage = false;
        if (rules[0].match(msg, cursor, rules, matchedFullMessage))
        {
            if (matchedFullMessage)
            {
                count_of_messages_that_match_the_rules += 1;
            }
        }
    }

    writeln("1: number of messages that match the rules = ",count_of_messages_that_match_the_rules);
}

/// 
void solve_19_2()
{
}
