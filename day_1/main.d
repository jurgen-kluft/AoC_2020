import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;

auto subRange(R)(R s, size_t beg, size_t end)
{
    return s.dropExactly(beg).take(end - beg);
}

unittest
{
    assert("abcçdef".subRange(2, 4).equal("cç"));
}

bool IsWhiteSpace(char c)
{
    return c == ' ' || c == '\t';
}

bool IsSignChar(char c)
{
    return c == '+' || c == '-';
}

bool IsIntegerChar(char c)
{
    return isDigit(c);
}

bool IsFloatChar(char c)
{
    return isDigit(c) || c == '.' || c == 'e' || IsSignChar(c);
}

size_t EatChar(string str, size_t i, char c)
{
    if (str[i] == c)
        return i + 1;
    return i;
}

size_t EatWhiteSpace(string str, size_t cursor)
{
    size_t i = cursor;
    while(i < str.length && IsWhiteSpace(str[i]))
        i+=1;
    return i;
}

size_t EatIntegerChars(string str, size_t cursor)
{
    size_t i = cursor;
    while(i < str.length && isDigit(str[i]))
        i+=1;
    return i;
}

size_t EatFloatChars(string str, size_t cursor)
{
    size_t i = cursor;
    while(i < str.length && IsFloatChar(str[i]))
        i+=1;
    return i;
}

size_t EatSignChar(string str, size_t cursor)
{
    if (IsSignChar(str[cursor]))
        return cursor + 1;
    return cursor;
}

size_t EatSeparator(string str, size_t cursor, char c)
{
    size_t i = cursor;
    i = EatWhiteSpace(str, i);
    i = EatChar(str, i, c);
    i = EatWhiteSpace(str, i);
    return i;
}

size_t Parse(string str, size_t cursor, ref int v)
{
    size_t i = cursor;
    i = EatWhiteSpace(str, i);
    size_t b = i;
    i = EatSignChar(str, i);
    i = EatIntegerChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!int(s);
    return i - cursor;
}

size_t Parse(string str, size_t cursor, ref ulong v)
{
    size_t i = cursor;
    i = EatWhiteSpace(str, i);
    size_t b = i;
    i = EatSignChar(str, i);
    i = EatIntegerChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!int(s);
    return i - cursor;
}

size_t Parse(string str, size_t cursor, ref float v)
{
    size_t i = cursor;
    i = EatWhiteSpace(str, i);
    size_t b = i;
    i = EatFloatChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!float(s);
    return i - cursor;
}

size_t Parse(string str, size_t cursor, ref double v)
{
    size_t i = cursor;
    i = EatWhiteSpace(str, i);
    size_t b = i;
    i = EatFloatChars(str, i);
    string s = str.subRange(b, i).text;
    v = to!double(s);
    return i - cursor;
}

class StringParser
{
public:
    this() { m_cursor = 0; m_str = ""; }
    
    void    Reset(string s)
    {
        m_cursor = 0;
        m_str = s;
    }

    StringParser Consume() // Consume whitespace
    {
        size_t i = m_cursor;
        i = EatWhiteSpace(m_str, i);
        m_cursor = i;
        return this;
    }

    StringParser Consume(size_t len) // Consume certain amount of characters
    {
        m_cursor += len;
        if (m_cursor > m_str.length)
            m_cursor = m_str.length;
        return this;
    }

    StringParser Consume(string str)
    {
        return Consume().Match(str).Consume();
    }

    StringParser Output()
    {
        string s = m_str.subRange(m_cursor, m_str.length).text;
        writeln(s);
        return this;
    }

    StringParser Match(string str)
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

    StringParser Parse(T)(ref T p)
    {
        size_t len = .Parse(m_str, m_cursor, p);
        return Consume(len);
    }

    StringParser Parse(T : int)(ref T v)
    {
        size_t len = .Parse(m_str, m_cursor, v);
        return Consume(len);
    }

    StringParser ParseInt32(ref int v)
    {
        size_t len = .Parse(m_str, m_cursor, v);
        return Consume(len);
    }

    StringParser ParseInt64(ref ulong v)
    {
        size_t len = .Parse(m_str, m_cursor, v);
        return Consume(len);
    }

    StringParser ParseF32(ref float f)
    {
        size_t len = .Parse(m_str, m_cursor, f);
        return Consume(len);
    }

    StringParser ParseF64(ref double d)
    {
        size_t len = .Parse(m_str, m_cursor, d);
        return Consume(len);
    }

private:
    size_t m_cursor;
    string m_str;
}




struct Point2(T)
{
    T m_x;
    T m_y;
}

size_t Parse(string str, size_t cursor, ref Point2!float p)
{
    float x, y;
    size_t i = cursor;

    i += Parse(str, i, x);
    i = EatSeparator(str, i, ',');
    i += Parse(str, i, y);

    p.m_x = x;
    p.m_y = y;
    return i - cursor;
}
size_t Parse(string str, size_t cursor, ref Point2!int p)
{
    int x, y;
    size_t i = cursor;

    i += Parse(str, i, x);
    i = EatSeparator(str, i, ',');
    i += Parse(str, i, y);

    p.m_x = x;
    p.m_y = y;
    return i - cursor;
}

struct Point3(T)
{
    T m_x;
    T m_y;
    T m_z;
}

size_t Parse(string str, size_t cursor, ref Point3!float p)
{
    float x, y, z;
    size_t i = cursor;

    i += Parse(str, i, x);
    i = EatSeparator(str, i, ',');
    i += Parse(str, i, y);
    i = EatSeparator(str, i, ',');
    i += Parse(str, i, z);

    p.m_x = x;
    p.m_y = y;
    p.m_z = z;
    return i - cursor;
}
size_t Parse(string str, size_t cursor, ref Point3!int p)
{
    int x, y, z;
    size_t i = cursor;

    i += Parse(str, i, x);
    i = EatSeparator(str, i, ',');
    i += Parse(str, i, y);
    i = EatSeparator(str, i, ',');
    i += Parse(str, i, z);

    p.m_x = x;
    p.m_y = y;
    p.m_z = z;
    return i - cursor;
}

void ReadFileLineByLine(string filename, void delegate(string line) cb)
{
    auto file = File(filename);
    auto range = file.byLine();
    foreach (l; range)
    {
        string line = l.text;
        cb(line);
    }
}


void main()
{
    auto parser = new StringParser();

    auto line = "point< 1.5 , 2.7 >15";
    Point2!float point;
    int i;
    parser.Reset(line);
    parser.Match("point").Match("<").Parse(point).Consume(">").Parse(i);
    writeln("x:", point.m_x, ", y:", point.m_y);
    writeln("i:", i);

    auto line2 = "point3< 1.4 , 2.7, 3.9 >";
    Point3!float point3;
    parser.Reset(line2);
    parser.Match("point3").Match("<").Parse(point3).Consume(">");
    writeln("x:", point3.m_x, ", y:", point3.m_y, ", z:", point3.m_z);

    Point2!int[] aposition;
    Point2!int[] avelocity;

    ReadFileLineByLine("input.text", (string line) {
        //writeln(line); 
        parser.Reset(line);

        Point2!int position;
        Point2!int velocity;
        
        // Example:  position=< 54347, -32361> velocity=<-5,  3>
        parser.Match("position=").Match("<").Parse(position).Consume(">").Match("velocity=").Match("<").Parse(velocity).Consume(">");
        writeln("  -> position=", position, "  velocity=", velocity);

        aposition ~= position;
        avelocity ~= velocity;
    });
    writeln("number of positions: ", aposition.length);
    writeln("number of velocities: ", avelocity.length);

}