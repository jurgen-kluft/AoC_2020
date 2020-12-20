module utilities.parser2;
import std.conv;
import std.stdio;
import core.vararg;

class tokenizer_t
{
    this()
    {

    }

    bool parse(string str, ref int cursor)
    {
        return false;
    }
}

class integer_t : tokenizer_t
{
    int * m_digit;
    int * m_count;

    this(int * d, int * count)
    {
        m_digit = d;
        m_count = count;
    }

    bool is_digit(char c)
    {
        return (c >= '0' && c <= '9');
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" integer_t");
        if (cursor == str.length)
            return false;

        int n = 0;
        if (is_digit(str[cursor]))
        {
            int start = cursor;
            while (cursor < str.length && is_digit(str[cursor]))
            {
                int d = str[cursor] - '0';
                n = (n*10) + d;
                cursor += 1;
            }
        }
        else
        {
            return false;
        }
        *m_digit = n;
        *m_count += 1;
        return true;
    }
}

class string_t : tokenizer_t
{
    string * m_str;
    int * m_count;

    this(string * c, int * count)
    {
        m_str = c;
        m_count = count;
    }

    bool is_alphabet(char c)
    {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
    }

    override bool parse(string str, ref int cursor)
    {
        int start = cursor;
        char[] rstr;
        while (cursor < str.length && is_alphabet(str[cursor]))
        {
            rstr ~= str[cursor];
            cursor += 1;
        }
        *m_str = rstr.text;
        *m_count += 1;
        return true;
    }
}

class is_t : tokenizer_t
{
    char m_c;

    this(char c)
    {
        m_c = c;
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" is_t");
        if (cursor < str.length)
        {
            char c = str[cursor];
            if (c == m_c)
            {
                cursor += 1;
                return true;
            }
        }
        return false;

    }
}

class whitespace_t : tokenizer_t
{
    this()
    {

    }

    override bool parse(string str, ref int cursor)
    {
        if (cursor < str.length && str[cursor] == ' ')
        {
            cursor += 1;
            return true;
        }
        return false;
    }
}

class between_t : tokenizer_t
{
    tokenizer_t m_a;
    int m_min;
    int m_max;
    this(tokenizer_t a, int min, int max)
    {
        m_a = a;
        m_min = min;
        m_max = max;
    }

    override bool parse(string str, ref int cursor)
    {
        int start = cursor;

        int count = 0;
        while (m_a.parse(str, cursor))
        {
            count++;
        }
        if (count>=m_min && count<=m_max)
        {
            return true;
        }
        cursor = start;
        return false;
    }
}

class once_t : between_t
{
    this(tokenizer_t a)
    {
        super(a, 1, 1);
    }
}

class zeroOrMore_t : between_t
{
    this(tokenizer_t a)
    {
        super(a, 0, int.max);
    }
}

class oneOrMore_t : between_t
{
    this(tokenizer_t a)
    {
        super(a, 1, int.max);
    }
}

class and_t : tokenizer_t
{
    tokenizer_t m_a;
    tokenizer_t m_b;
    this(tokenizer_t a, tokenizer_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" and_t");
        int start1 = cursor;
        bool result1 = m_a.parse(str, start1);
        if (!result1)
        {
            return false;
        }
        int start2 = cursor;
        bool result2 = m_b.parse(str, start2);
        if (!result2)
        {
            return false;
        }
        int start = (start1 > start2) ? start1 : start2;
        cursor = start;
        return true;
    }
}

class eol_t : tokenizer_t
{
    this()
    {

    }

    override bool parse(string str, ref int cursor)
    {
        //write(" eol_t");
        return cursor == str.length;
    }

}

class or_t : tokenizer_t
{
    tokenizer_t m_a;
    tokenizer_t m_b;
    this(tokenizer_t a, tokenizer_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" or_t");
        if (!m_a.parse(str, cursor))
        {
            if (!m_b.parse(str, cursor))
            {
                return false;
            }
        }
        return true;
    }
}

class seq_t : tokenizer_t
{
    tokenizer_t[] m_items;
    
    this(tokenizer_t a, ...)
    {
        m_items ~= a;
        for (int i = 0; i < _arguments.length; i++)
        {
            tokenizer_t t = va_arg!(tokenizer_t)(_argptr);
            m_items ~= t;
        }        
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" seq_t");

        int start = cursor;
        foreach(item; m_items)
        {
            if (!item.parse(str, cursor))
            {
                cursor = start;
                return false;
            }
        }
        return true;
    }
}

