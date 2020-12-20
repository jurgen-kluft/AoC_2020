module puzzles.puzzle18;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism : parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

const byte NUMBER = 1;
const byte EXPRESSION = 2;
const byte ADD = 10;
const byte SUB = 11;
const byte MUL = 12;
const byte DIV = 13;

class expression_t
{
    string m_equation;
    long[] m_numbers;
    expression_t[] m_expressions;
    byte[] m_operations;

    this()
    {
    }

    long evaluate_for_rule1()
    {
        long vi = 0;

        long an = m_numbers[vi];
        expression_t ae = m_expressions[vi];
        const byte ao = m_operations[vi++];
        if (ao == EXPRESSION)
            an = ae.evaluate_for_rule1();

        while (vi < m_operations.length)
        {
            const byte o = m_operations[vi++];

            long bn = m_numbers[vi];
            expression_t be = m_expressions[vi];
            const byte bo = m_operations[vi++];
            if (bo == EXPRESSION)
                bn = be.evaluate_for_rule1();

            // Evaluate additions first
            if (o == MUL)
            {
                const long cn = an * bn;
                an = cn;
            }
            else if (o == ADD)
            {
                const long cn = an + bn;
                an = cn;
            }
        }
        return an;
    }

    long evaluate_for_rule2()
    {
        long vi = 0;

        long an = m_numbers[vi];
        expression_t ae = m_expressions[vi];
        byte ao = m_operations[vi++];
        if (ao == EXPRESSION)
        {
            an = ae.evaluate_for_rule2();
            ao = NUMBER;
            ae = null;
        }

        // Where we store the resulting multiplication data
        long[] numbers;
        expression_t[] expressions;
        byte[] operations;

        // First compute all additions
        while (vi < m_operations.length)
        {
            byte o = m_operations[vi++];
            // o == MUL or ADD

            long bn = m_numbers[vi];
            expression_t be = m_expressions[vi];
            byte bo = m_operations[vi++];
            if (bo == EXPRESSION)
            {
                bn = be.evaluate_for_rule2();
                be = null;
                bo = NUMBER;
            }

            if (o == MUL)
            {
                numbers ~= an;          // a
                expressions ~= ae;
                operations ~= ao;

                numbers ~= 0;           // *
                expressions ~= null;
                operations ~= o;

                an = bn;
                ae = be;
                ao = bo;
            }
            else
            {
                // Evaluate additions first
                long cn = an + bn;
                expression_t ce = null;
                byte co = NUMBER;

                // a + b = c, two operations now are one
                an = cn;
                ae = ce;
                ao = co;
            }
        }

        numbers ~= an;          // a
        expressions ~= ae;
        operations ~= ao;

        vi = 0;

        an = numbers[vi];
        ae = expressions[vi];
        ao = operations[vi++];
        if (ao == EXPRESSION)
        {
            an = ae.evaluate_for_rule2();
            ao = NUMBER;
            ae = null;
        }

        while (vi < operations.length)
        {
            byte o = operations[vi++];

            long bn = numbers[vi];
            expression_t be = expressions[vi];
            byte bo = operations[vi++];
            if (bo == EXPRESSION)
            {
                bn = be.evaluate_for_rule2();
                be = null;
                bo = NUMBER;
            }

            if (o == MUL)
            {
                long cn = an * bn;
                expression_t ce = null;
                byte co = NUMBER;

                an = cn;
                ae = ce;
                ao = co;
            }
        }        

        return an;
    }

    long parse_number(string str, long cursor, ref long value)
    {
        value = 0;
        while (cursor < str.length && str[cursor] >= '0' && str[cursor] <= '9')
        {
            long d = (str[cursor] - '0');
            value = (value * 10) + d;
            cursor += 1;
        }
        return cursor;
    }

    long whitespace(string str, long cursor)
    {
        while (cursor < str.length && str[cursor] == ' ')
            cursor++;
        return cursor;
    }

    long parse(string str, long cursor)
    {
        if (cursor == str.length)
            return cursor;

        cursor = whitespace(str, cursor);
        while (cursor < str.length && str[cursor] != ')')
        {
            if (str[cursor] == '(')
            {
                expression_t ex = new expression_t();
                cursor = ex.parse(str, cursor + 1);
                m_expressions ~= ex;
                m_numbers ~= 0;
                m_operations ~= EXPRESSION;
            }
            else if (str[cursor] >= '0' && str[cursor] <= '9')
            {
                long value;
                cursor = parse_number(str, cursor, value);
                m_numbers ~= value;
                m_operations ~= NUMBER;
                m_expressions ~= null;
            }
            else if (str[cursor] == '*')
            {
                m_operations ~= MUL;
                m_expressions ~= null;
                m_numbers ~= 0;
                cursor += 1;
            }
            else if (str[cursor] == '+')
            {
                m_operations ~= ADD;
                m_expressions ~= null;
                m_numbers ~= 0;
                cursor += 1;
            }
            cursor = whitespace(str, cursor);
        }

        cursor += 1;
        return cursor;
    }
}

/// 
void solve_18_1()
{
    expression_t[] equations;
    {
        auto parser = new InputParser();
        readFileLineByLine("input/input_18.text", (string line) {
            parser.reset(line);
            if (line.length == 0)
                return;

            expression_t eq = new expression_t();
            eq.m_equation = line;
            eq.parse(line, 0);
            equations ~= eq;
        });
    }
    writeln("number of equations parsed = ", equations.length);

    //expression_t eq = equations[0];
    //long result = eq.evaluate();
    //writeln(eq.m_equation, " = ", result);

    long sum_of_all_results = 0;
    foreach (eq; equations)
    {
        const long result = eq.evaluate_for_rule1();
        //writeln(eq.m_equation, " = ", result);
        sum_of_all_results += result;
    }

    writeln("1: Sum of all results = ", sum_of_all_results);
}

/// 
void solve_18_2()
{
    expression_t[] equations;
    {
        auto parser = new InputParser();
        readFileLineByLine("input/input_18.text", (string line) {
            parser.reset(line);
            if (line.length == 0)
                return;

            expression_t eq = new expression_t();
            eq.m_equation = line;
            eq.parse(line, 0);
            equations ~= eq;
        });
    }
    writeln("number of equations parsed = ", equations.length);

    //expression_t eq = equations[0];
    //long result = eq.evaluate();
    //writeln(eq.m_equation, " = ", result);

    long sum_of_all_results = 0;
    foreach (eq; equations)
    {
        const long result = eq.evaluate_for_rule2();
        //writeln(eq.m_equation, " = ", result);
        sum_of_all_results += result;
    }

    writeln("1: Sum of all results = ", sum_of_all_results);
}
