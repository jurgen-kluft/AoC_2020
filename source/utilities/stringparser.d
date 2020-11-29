module utilities.stringparser;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;

/// subRange will return a sub part of a string
auto subRange(R)(R s, size_t beg, size_t end)
{
    return s.dropExactly(beg).take(end - beg);
}

unittest
{
    assert("abcçdef".subRange(2, 4).equal("cç"));
}

/// isWhiteSpace returns true if char is ' ' or '\t'
bool isWhiteSpace(char c)
{
    return c == ' ' || c == '\t';
}

/// isSignChar returns true if char is minus or positive sign character
bool isSignChar(char c)
{
    return c == '+' || c == '-';
}

/// isIntegerChar returns true if char is any of '0'-'9'
bool isIntegerChar(char c)
{
    return isDigit(c);
}

///
bool isFloatChar(char c)
{
    return isDigit(c) || c == '.' || c == 'e' || isSignChar(c);
}

///
size_t eatChar(string str, size_t i, char c)
{
    if (str[i] == c)
        return 1;
    return 0;
}

///
size_t eatWhiteSpace(string str, size_t cursor)
{
    size_t i = cursor;
    while (i < str.length && isWhiteSpace(str[i]))
        i += 1;
    return i - cursor;
}

///
size_t eatIntegerChars(string str, size_t cursor)
{
    size_t i = cursor;
    while (i < str.length && isDigit(str[i]))
        i += 1;
    return i - cursor;
}

///
size_t eatFloatChars(string str, size_t cursor)
{
    size_t i = cursor;
    while (i < str.length && isFloatChar(str[i]))
        i += 1;
    return i - cursor;
}

/// 
size_t eatSignChar(string str, size_t cursor)
{
    if (isSignChar(str[cursor]))
        return 1;
    return 0;
}

/// 
size_t eatSeparator(string str, size_t cursor, char c)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    i += eatChar(str, i, c);
    i += eatWhiteSpace(str, i);
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref int v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatSignChar(str, i);
    i += eatIntegerChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!int(s);
    return i - cursor;
}

/// 
size_t parse(string str, size_t cursor, ref ulong v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatSignChar(str, i);
    i += eatIntegerChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!int(s);
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref float v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatFloatChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!float(s);
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref double v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatFloatChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!double(s);
    return i - cursor;
}

/// 
class StringParser
{
public:
    ///
    this()
    {
        m_cursor = 0;
        m_str = "";
    }

    ///
    void reset(string s)
    {
        m_cursor = 0;
        m_str = s;
    }

    ///
    StringParser consume() // Consume whitespace
    {
        size_t i = m_cursor;
        i += eatWhiteSpace(m_str, i);
        m_cursor = i;
        return this;
    }

    ///
    StringParser consume(size_t len) // Consume certain amount of characters
    {
        m_cursor += len;
        if (m_cursor > m_str.length)
            m_cursor = m_str.length;
        return this;
    }

    ///
    StringParser consume(string str)
    {
        return consume().match(str).consume();
    }

    ///
    StringParser output()
    {
        string s = m_str.subRange(m_cursor, m_str.length).text;
        writeln(s);
        return this;
    }

    ///
    StringParser match(string str)
    {
        size_t i = 0;
        while (i < str.length && (m_cursor + i) < m_str.length)
        {
            if (str[i] != m_str[m_cursor + i])
            {
                i = 0;
                break;
            }
            i++;
        }
        if (i == str.length)
            m_cursor += i;
        return this;
    }

    /// parse can parse a custom type
    StringParser parse(T)(ref T p)
    {
        size_t len = .parse(m_str, m_cursor, p);
        return consume(len);
    }

private:
    size_t m_cursor;
    string m_str;
}

///
struct Point2(T)
{
    T m_x;
    T m_y;
}

///
size_t parse(string str, size_t cursor, ref Point2!float p)
{
    float x, y;
    size_t i = cursor;

    i += parse(str, i, x);
    i += eatSeparator(str, i, ',');
    i += parse(str, i, y);

    p.m_x = x;
    p.m_y = y;
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref Point2!int p)
{
    int x = 0;
    int y = 0;
    size_t i = cursor;

    i += parse(str, i, x);
    i += eatSeparator(str, i, ',');
    i += parse(str, i, y);

    p.m_x = x;
    p.m_y = y;
    return i - cursor;
}

///
struct Point3(T)
{
    T m_x;
    T m_y;
    T m_z;
}

///
size_t parse(string str, size_t cursor, ref Point3!float p)
{
    float x, y, z;
    size_t i = cursor;

    i += parse(str, i, x);
    i += eatSeparator(str, i, ',');
    i += parse(str, i, y);
    i += eatSeparator(str, i, ',');
    i += parse(str, i, z);

    p.m_x = x;
    p.m_y = y;
    p.m_z = z;
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref Point3!int p)
{
    int x, y, z;
    size_t i = cursor;

    i += parse(str, i, x);
    i += eatSeparator(str, i, ',');
    i += parse(str, i, y);
    i += eatSeparator(str, i, ',');
    i += parse(str, i, z);

    p.m_x = x;
    p.m_y = y;
    p.m_z = z;
    return i - cursor;
}

///
void readFileLineByLine(string filename, void delegate(string line) cb)
{
    auto file = File(filename);
    auto range = file.byLine();
    foreach (l; range)
    {
        string line = l.text;
        cb(line);
    }
}

void test_stringparser()
{
    auto parser = new StringParser();

    auto line = "point< 1.5 , 2.7 >15";
    Point2!float point;
    int i;
    parser.reset(line);
    parser.match("point").match("<").parse(point).consume(">").parse(i);
    writeln("x:", point.m_x, ", y:", point.m_y);
    writeln("i:", i);

    auto line2 = "Point3< 1.4 , 2.7, 3.9 >";
    Point3!float Point3;
    parser.reset(line2);
    parser.match("Point3").match("<").parse(Point3).consume(">");
    writeln("x:", Point3.m_x, ", y:", Point3.m_y, ", z:", Point3.m_z);

    Point2!int[] aposition;
    Point2!int[] avelocity;

    readFileLineByLine("input/input_1_1.text", (string line) {
        //writeln(line); 
        parser.reset(line);

        Point2!int position;
        Point2!int velocity;

        // Example:  position=< 54347, -32361> velocity=<-5,  3>
        parser.match("position=").match("<").parse(position).consume(">")
            .match("velocity=").match("<").parse(velocity).consume(">");
        writeln("  -> position=", position, "  velocity=", velocity);

        aposition ~= position;
        avelocity ~= velocity;
    });
    writeln("number of positions: ", aposition.length);
    writeln("number of velocities: ", avelocity.length);

}
