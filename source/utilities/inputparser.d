module utilities.inputparser;

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

size_t match(string str, size_t cursor, string m)
{
    size_t i = 0;
    while (i < m.length && (cursor + i) < str.length)
    {
        if (m[i] != str[cursor + i])
        {
            i = 0;
            break;
        }
        i++;
    }
    if (i == m.length)
    {
        return i;
    }
    return 0;
}

/// isWhiteSpace returns true if char is ' ' or '\t'
bool isWhiteSpace(char c)
{
    return c == ' ' || c == '\t';
}

bool isLetter(char c)
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

bool isHex(char c)
{
    return (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
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
    if (i < str.length && str[i] == c)
        return 1;
    return 0;
}

///
size_t eatChars(string str, size_t cursor)
{
    size_t i = cursor;
    while (i < str.length && !isWhiteSpace(str[i]))
        i += 1;
    return i - cursor;
}

///
size_t eatCharsUntil(string str, size_t cursor, char until)
{
    size_t i = cursor;
    while (i < str.length && (str[i] != until))
        i += 1;
    return i - cursor;
}

///
size_t eatLetters(string str, size_t cursor)
{
    size_t i = cursor;
    while (i < str.length && isLetter(str[i]))
        i += 1;
    return i - cursor;
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
size_t eatHexChars(string str, size_t cursor)
{
    size_t i = cursor;
    while (i < str.length && (isDigit(str[i]) || isHex(str[i])))
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
    if (cursor < str.length && isSignChar(str[cursor]))
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
size_t parse(string str, size_t cursor, ref char v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += 1;
    i += eatWhiteSpace(str, i);
    if (b > i)
    {
        string s = str.subRange(b, i).text;
        v = to!char(s);
    }
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref char[] v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatLetters(str, i);
    i += eatWhiteSpace(str, i);

    if (b > i)
    {
        auto txt = str.subRange(b, i).text;
        foreach(char c; txt)
        {
            v ~= c;
        }
    }

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
    if (i > b)
    {
        string s = str.subRange(b, i).text;
        v = to!int(s);
    }
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
    if (i > b)
    {
        string s = str.subRange(b, i).text;
        v = to!int(s);
    }
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref float v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatFloatChars(str, i);
    if (i > b)
    {
        string s = str.subRange(b, i).text;
        v = to!float(s);
    }
    return i - cursor;
}

///
size_t parse(string str, size_t cursor, ref double v)
{
    size_t i = cursor;
    i += eatWhiteSpace(str, i);
    size_t b = i;
    i += eatFloatChars(str, i);
    if (i > b)
    {
        string s = str.subRange(b, i).text;
        v = to!double(s);
    }
    return i - cursor;
}

/// 
class InputParser
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

    bool at_end()
    {
        return m_cursor >= m_str.length;
    }

    ///
    InputParser consume() // Consume whitespace
    {
        size_t i = m_cursor;
        i += eatWhiteSpace(m_str, i);
        m_cursor = i;
        return this;
    }

    ///
    InputParser consume(size_t len) // Consume certain amount of characters
    {
        m_cursor += len;
        if (m_cursor > m_str.length)
            m_cursor = m_str.length;
        return this;
    }

    ///
    InputParser consume(string str)
    {
        consume();
        match(str);
        return consume();
    }

    ///
    InputParser output()
    {
        string s = m_str.subRange(m_cursor, m_str.length).text;
        writeln(s);
        return this;
    }

    ///
    bool is_match(string str)
    {
        size_t i = .match(m_str, m_cursor, str);
        m_cursor += i;
        return i > 0;
    }

    ///
    InputParser match(string str)
    {
        size_t i = .match(m_str, m_cursor, str);
        m_cursor += i;
        return this;
    }

    InputParser read(ref char p)
    {
        if (!at_end())
        {
            p = m_str[m_cursor++];
        }
        else
        {
            p = '?';
        }
        return this;
    }

    /// parse can parse a custom type
    InputParser parse(T)(ref T p)
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

struct Height
{
    int value;
    int units;  // 1 = cm, 2 = inch
}

///
size_t parse(string str, size_t cursor, ref Height h)
{
    size_t i = cursor;
    size_t b = i;
    i += eatIntegerChars(str, i);

    int unit = 1;
    int unitlen = 0;
    if ((i+1) < str.length)
    {
        if (str[i] == 'i' && str[i+1]=='n')
        {
            unit = 2;
            unitlen = 2;
        }
        if (str[i] == 'c' && str[i+1]=='m')
        {
            unit = 1;
            unitlen = 2;
        }
    }

    if (unit > 0)
    {
        string s = str.subRange(b, i).text;
        uint radix = 16;
        h.value = std.conv.parse!int(s, radix);
        h.units = unit;
        i += unitlen; // skip unit
        return i - cursor;
    }
    else if (str[i] == 'i' && str[i+1]=='n')
    {
    }
    return 0;
}

struct Color
{
    int color;
}

///
size_t parse(string str, size_t cursor, ref Color c)
{
    size_t i = cursor;
    if (str[i] == '#')
    {
        i += 1;
    }
    size_t b = i;
    i += eatChars(str, i);
    if (i > b && ((i-b) > 3))
    {
        string s = str.subRange(b, i).text;
        c.color = std.conv.parse!int(s, 16);
    }
    else
    {
        c.color = 111111;
    }
    return i - cursor;
}

struct KeyValue
{
    char seperator;
    string key;
    string value;
}

///
size_t parse(string str, size_t cursor, ref KeyValue kv)
{
    size_t i = cursor;

    if (i < str.length)
    {
        size_t b = i;
        i += eatCharsUntil(str, i, kv.seperator);
        {
            kv.key = str.subRange(b, i).text;
        }
        if (i < str.length && str[i] == kv.seperator)
        {
            i += 1;
            b = i;
            i += eatChars(str, i);
            {
                kv.value = str.subRange(b, i).text;
            }
        }
    }
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

void test_parser()
{
    auto parser = new InputParser();

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
