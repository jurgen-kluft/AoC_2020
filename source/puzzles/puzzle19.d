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
public:    
    abstract bool match(string msg, ref int cursor, rule_t[int] ops);
}

class match_t : operation_t
{
    char m_str;

public:    
    this(char str)
    {
        m_str = str;
    }

    override bool match(string msg, ref int cursor, rule_t[int] ops)
    {
        if (cursor == msg.length)
            return false;

        if (m_str == msg[cursor])
        {
            cursor += 1;
            return true;
        }
        return false;
    }
}

class ref_t : operation_t
{
    int m_index;

public:    
    this(int index)
    {
        m_index = index;
    }

    override bool match(string msg, ref int cursor, rule_t[int] ops)
    {
        int start = cursor;
        const bool a = ops[m_index].match(msg, cursor, ops);
        if (!a)
            cursor = start;
        return a;
    }
}

class and_t : operation_t
{
    operation_t[] m_o;

public:    
    this(operation_t[] o)
    {
        m_o = o;
    }

    override bool match(string msg, ref int cursor, rule_t[int] ops)
    {
        int start = cursor;
        foreach(o; m_o)
        {
            const bool result = o.match(msg, cursor, ops);
            if (!result)
            {
                cursor = start;
                return false;
            }
        }
        return true;
    }
}

class or_t : operation_t
{
    operation_t m_a;
    operation_t m_b;

public:    
    this(operation_t a, operation_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool match(string msg, ref int cursor, rule_t[int] ops)
    {
        int start = cursor;
        const bool a = m_a.match(msg, cursor, ops);
        if (!a)
        {
            const bool b = m_b.match(msg, cursor, ops);
            if (!b)
                cursor = start;
            return b;
        }
        return a;
    }
}

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

    this(int index, parser.Vars lvars, parser.Vars rvars)
    {
        m_index = index;

        operation_t lop = null;
        {
            const int lcount = lvars.Count();
            if (lcount > 1)
            {
                operation_t[] lrefs;
                for (int i=0; i<lcount; i++)
                {
                    lrefs ~= new ref_t(lvars[i]);
                }
                lop = new and_t(lrefs);
            }
            else if (lcount == 1)
            {
                lop = new ref_t(lvars[0]);
            }
        }

        operation_t rop = null;
        {
            const int rcount = rvars.Count();
            if (rcount > 1)
            {
                operation_t[] rrefs;
                for (int i=0; i<rcount; i++)
                {
                    rrefs ~= new ref_t(rvars[i]);
                }
                rop = new and_t(rrefs);
            }
            else if (rcount == 1)
            {
                rop = new ref_t(rvars[0]);
            }
        }

        if (rop !is null)
        {
            m_op = new or_t(lop, rop);
        }
        else if (lop !is null)
        {
            m_op = lop;
        }
        else
        {
            writeln(index, ": ", lvars.m_vars, " / ", rvars.m_vars, " -> error!");
        }
    }

    bool match(string msg, ref int cursor, rule_t[int] ops)
    {
        return m_op.match(msg, cursor, ops);
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

    parser.Var idx = new parser.Var();
    parser.Vars lvars = new parser.Vars();
    parser.Vars rvars = new parser.Vars();
    parser.Text r1c = new parser.Text();
    parser.Seq parseRule = new parser.Seq(
        new parser.Index(idx),
        new parser.Is(':'),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.Or(
            new parser.Seq(
                new parser.Is('"'),
                new parser.String(r1c),
                new parser.Is('"'),
                new parser.ZeroOrMore(new parser.Whitespace()),
                new parser.EOL()
            ),
            new parser.Seq(
                new parser.ZeroOrMore(new parser.Whitespace()),
                new parser.Until(new parser.Or(new parser.Is('|'), new parser.EOL()), 
                    new parser.Seq(
                        new parser.ZeroOrMore(new parser.Whitespace()),
                        //new parser.Print("marker 1"),
                        new parser.Integer(lvars),
                        new parser.ZeroOrMore(new parser.Whitespace())
                    )
                ),
                new parser.Or(
                    new parser.EOL(),
                    new parser.Seq(
                        new parser.Until(new parser.EOL(), 
                            new parser.Seq(
                                new parser.ZeroOrMore(new parser.Whitespace()),
                                //new parser.Print("marker 2"),
                                new parser.Integer(rvars),
                                new parser.ZeroOrMore(new parser.Whitespace())
                            )
                        )
                    )
                )
            )
        )
    );

    bool do_test = false;
    if (do_test)
    {
        int cursor = 0;
        string[] lines;
        lines ~= `45: "a"`;
        lines ~= "45: 46";
        lines ~= "45: 46 58";
        lines ~= "45: 46 | 58";
        lines ~= "45: 46 52 | 9 72";
        lines ~= "8: 42 | 42 8";
        lines ~= "11: 42 31 | 42 11 31";
        lines ~= "200: 42 42 42 42 42 42 31 31 31 31 31 31 | 210";

        foreach(line; lines)
        {
            cursor = 0;
            idx.Reset();
            rvars.Reset();
            lvars.Reset();
            idx.Reset();
            r1c.Reset();
            if (parseRule.parse(line, cursor))
            {
                writeln("lvars: ", lvars.m_vars);
                writeln("rvars: ", rvars.m_vars);
                writeln(line, "           is OK!");
            }
            else
            {
                writeln(line, "           is NOT Ok!");
            }
            writeln();
        }
    }

    rule_t[int] rules;
    string[] msgs;

    int state = PARSE_RULES;
    int cursor = 0;

    readFileLineByLine("input/input_19.text", (string line) {
        if ((line.length == 0) || (line == ""))
        {
            state = PARSE_MESSAGES;
            return;
        }

        if (state == PARSE_RULES)
        {
            cursor = 0;
            idx.Reset();
            rvars.Reset();
            lvars.Reset();
            idx.Reset();
            r1c.Reset();
            if (parseRule.parse(line, cursor))
            {
                if (lvars.Count() == 0 && rvars.Count() == 0 && r1c.Count() == 1)
                {
                    string txt = r1c.Get(0);
                    rules[idx.Get()] = new rule_t(idx.Get(), txt[0]);
                }
                else
                {
                    rules[idx.Get()] = new rule_t(idx.Get(), lvars, rvars);
                }
            }
            else
            {
                writeln(state, ": parse error; cannot parse rule: ", '"', line, '"');
            }
        }
        else if (state == PARSE_MESSAGES)
        {
            msgs ~= line;
        }
    });

    writeln("number of rules: ", rules.length);
    writeln("number of messages: ", msgs.length);

    int count_of_messages_that_match_the_rules = 0;
    foreach(msg; msgs)
    {
        cursor = 0;
        if (rules[0].match(msg, cursor, rules))
        {
            if (cursor == msg.length)
            {
                count_of_messages_that_match_the_rules += 1;
            }
            else
            {
                //writeln("Only matched ", cursor, " characters of the message that is ", msg.length, " long");
            }
        }
    }

    writeln("1: number of messages that match the rules = ",count_of_messages_that_match_the_rules);

}

void solve_19_2()
{

    // Examples
    // 0: 8 11
    // 45: 46 52 | 9 72
    // 8: 42
    parser.Var idx = new parser.Var();
    parser.Vars lvars = new parser.Vars();
    parser.Vars rvars = new parser.Vars();
    parser.Text r1c = new parser.Text();
    parser.Seq parseRule = new parser.Seq(
        new parser.Index(idx),
        new parser.Is(':'),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.Or(
            new parser.Seq(
                new parser.Is('"'),
                new parser.String(r1c),
                new parser.Is('"'),
                new parser.ZeroOrMore(new parser.Whitespace()),
                new parser.EOL()
            ),
            new parser.Seq(
                new parser.ZeroOrMore(new parser.Whitespace()),
                new parser.Until(new parser.Or(new parser.Is('|'), new parser.EOL()), 
                    new parser.Seq(
                        new parser.ZeroOrMore(new parser.Whitespace()),
                        //new parser.Print("marker 1"),
                        new parser.Integer(lvars),
                        new parser.ZeroOrMore(new parser.Whitespace())
                    )
                ),
                new parser.Or(
                    new parser.EOL(),
                    new parser.Seq(
                        new parser.Until(new parser.EOL(), 
                            new parser.Seq(
                                new parser.ZeroOrMore(new parser.Whitespace()),
                                //new parser.Print("marker 2"),
                                new parser.Integer(rvars),
                                new parser.ZeroOrMore(new parser.Whitespace())
                            )
                        )
                    )
                )
            )
        )
    );

    rule_t[int] rules;
    string[] msgs;

    int cursor = 0;
    int state = PARSE_RULES;

    readFileLineByLine("input/input_19.text", (string line) {
        if ((line.length == 0) || (line == ""))
        {
            state = PARSE_MESSAGES;
            return;
        }

        if (state == PARSE_RULES)
        {
            string[] lines;

            // Rules 0, 8 and 11 are to be replaced
            if (startsWith(line, "0:"))
            {
                writeln("Changing rule 0");
                lines ~= "0: 11";
            }
            else if (startsWith(line, "8:"))
            {
                writeln("Changing rule 8");

                //line = "8: 42 | 42 8";
                lines ~= "8: 42";
            }
            else if (startsWith(line, "11:"))
            {
                writeln("Changing rule 11");
                
                //@NOTE: Unwrap the loop a couple of times

                //line = "11: 42 31 | 42 11 31";
                lines ~= "11: 200";
                lines ~= "200: 42 42 42 42 42 42 42 42 42 42 31 31 31 31 31 | 201";
                lines ~= "201: 42 42 42 42 42 42 42 42 42 31 31 31 31 31 | 202";
                lines ~= "202: 42 42 42 42 42 42 42 42 31 31 31 31 31 | 203";
                lines ~= "203: 42 42 42 42 42 42 42 31 31 31 31 31 | 204";
                lines ~= "204: 42 42 42 42 42 42 31 31 31 31 31 | 205";
                lines ~= "205: 42 42 42 42 42 42 42 42 42 31 31 31 31 | 206";
                lines ~= "206: 42 42 42 42 42 42 42 42 31 31 31 31 | 207";
                lines ~= "207: 42 42 42 42 42 42 42 31 31 31 31 | 208";
                lines ~= "208: 42 42 42 42 42 42 31 31 31 31 | 209";
                lines ~= "209: 42 42 42 42 42 31 31 31 31 | 210";
                lines ~= "210: 42 42 42 42 42 42 42 42 31 31 31 | 211";
                lines ~= "211: 42 42 42 42 42 42 42 31 31 31 | 212";
                lines ~= "212: 42 42 42 42 42 42 31 31 31 | 213";
                lines ~= "213: 42 42 42 42 42 31 31 31 | 214";
                lines ~= "214: 42 42 42 42 31 31 31 | 215";
                lines ~= "215: 42 42 42 42 42 42 42 31 31 | 216";
                lines ~= "216: 42 42 42 42 42 42 31 31 | 217";
                lines ~= "217: 42 42 42 42 42 31 31 | 218";
                lines ~= "218: 42 42 42 42 31 31 | 219";
                lines ~= "219: 42 42 42 31 31 | 220";
                lines ~= "220: 42 42 42 42 42 42 31 | 221";
                lines ~= "221: 42 42 42 42 42 31 | 222";
                lines ~= "222: 42 42 42 42 31 | 223";
                lines ~= "223: 42 42 42 31 | 224";
                lines ~= "224: 42 42 31";
            }
            else
            {
                lines ~= line;
            }

            foreach(l; lines)
            {
                cursor = 0;
                cursor = 0;
                idx.Reset();
                rvars.Reset();
                lvars.Reset();
                idx.Reset();
                r1c.Reset();
                if (parseRule.parse(l, cursor))
                {
                    if (lvars.Count() == 0 && rvars.Count() == 0 && r1c.Count() == 1)
                    {
                        string txt = r1c.Get(0);
                        rules[idx.Get()] = new rule_t(idx.Get(), txt[0]);
                    }
                    else
                    {
                        rules[idx.Get()] = new rule_t(idx.Get(), lvars, rvars);
                    }
                }
                else
                {
                    writeln(state, ": parse error; cannot parse rule: ", '"', l, '"');
                }
            }
        }
        else if (state == PARSE_MESSAGES)
        {
            msgs ~= line;
        }
    });

    writeln("number of rules: ", rules.length);
    writeln("number of messages: ", msgs.length);

    int count_of_messages_that_match_the_rules = 0;
    foreach(msg; msgs)
    {
        cursor = 0;
        if (rules[0].match(msg, cursor, rules))
        {
            if (cursor == msg.length)
            {
                count_of_messages_that_match_the_rules += 1;
            }
            else
            {
                //writeln("Only matched ", cursor, " characters of the message that is ", msg.length, " long");
            }
        }
    }

    writeln("2: number of messages that match the rules = ",count_of_messages_that_match_the_rules);

}
