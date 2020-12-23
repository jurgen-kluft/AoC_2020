module utilities.parser2;
import std.conv;
import std.stdio;
import core.vararg;

class Tokenizer_t
{
    abstract bool parse(string str, ref int cursor);
}

class Var
{
    int m_var;

    void Set(int v)
    {
        m_var = v;
    }

    int Get()
    {
        return m_var;
    }

    void Reset()
    {
        m_var = -1;
    }
}

class Vars
{
    int[] m_vars;

    void Push(int v)
    {
        m_vars ~= v;
    }

    int Count()
    {
        return cast(int)m_vars.length;
    }
    
    int opIndex(int i) { return m_vars[i]; }

    void Reset()
    {
        m_vars.length = 0;
    }
}

class Text
{
    string[] m_text;

    void Set(string txt)
    {
        m_text ~= txt;
    }

    string Get(int i)
    {
        return m_text[i];
    }

    int Count()
    {
        return cast(int)m_text.length;
    }

    void Reset()
    {
        m_text.length = 0;
    }
}

class Index : Tokenizer_t
{
    Var m_var;

    this(Var v)
    {
        m_var = v;
    }

    bool is_digit(char c)
    {
        return (c >= '0' && c <= '9');
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" Integer");
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
        m_var.Set(n);
        return true;
    }
}

class Integer : Tokenizer_t
{
    Vars m_vars;

    this(Vars v)
    {
        m_vars = v;
    }

    bool is_digit(char c)
    {
        return (c >= '0' && c <= '9');
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" Integer");
        if (cursor == str.length)
            return false;

        int n = 0;
        if (is_digit(str[cursor]))
        {
            while (cursor < str.length && is_digit(str[cursor]))
            {
                int d = str[cursor] - '0';
                n = (n*10) + d;
                cursor += 1;
            }
        }
        else
        {
            writeln("no digit starts here ", cursor, " = ", str[cursor]);
            return false;
        }
        m_vars.Push(n);
        return true;
    }
}

class String : Tokenizer_t
{
    Text m_text;

    this(Text t)
    {
        m_text = t;
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
        m_text.Set(rstr.text);
        return true;
    }
}

class Exact: Tokenizer_t
{
    string m_str;

    this(string str)
    {
        m_str = str;
    }

    override bool parse(string str, ref int cursor)
    {
        int start = cursor;
        int i = 0;
        while (cursor < str.length && i < m_str.length)
        {
            if (str[cursor] != m_str[i])
            {
                cursor = start;
                return false;
            }
            i += 1;
            cursor += 1;
        }
        return true;
    }
}

class Is : Tokenizer_t
{
    char m_c;

    this(char c)
    {
        m_c = c;
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" Is");
        if (cursor < str.length && (str[cursor] == m_c))
        {
            cursor += 1;
            return true;
        }
        return false;

    }
}

class Whitespace : Tokenizer_t
{
    this() {}

    override bool parse(string str, ref int cursor)
    {
        if ((cursor < str.length) && (str[cursor] == ' ' || str[cursor] == '\t'))
        {
            cursor += 1;
            return true;
        }
        return false;
    }
}

class Until : Tokenizer_t
{
    Tokenizer_t m_until;
    Tokenizer_t m_entry;
    this(Tokenizer_t until, Tokenizer_t entry)
    {
        m_until = until;
        m_entry = entry;
    }

    override bool parse(string str, ref int cursor)
    {
        int start = cursor;
        while (!m_until.parse(str, cursor))
        {
            if (!m_entry.parse(str, cursor))
            {
                cursor = start;
                return false;
            }
        }
        return true;
    }

}

class Counted : Tokenizer_t
{
    Tokenizer_t m_a;
    int m_min;
    int m_max;
    this(Tokenizer_t a, int min, int max)
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

class Once : Counted
{
    this(Tokenizer_t a)
    {
        super(a, 1, 1);
    }
}

class ZeroOrMore : Counted
{
    this(Tokenizer_t a)
    {
        super(a, 0, 0x7fffffff);
    }
}

class OneOrMore : Counted
{
    this(Tokenizer_t a)
    {
        super(a, 1, 0x7fffffff);
    }
}

class And : Tokenizer_t
{
    Tokenizer_t m_a;
    Tokenizer_t m_b;
    this(Tokenizer_t a, Tokenizer_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" And");
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

class Print : Tokenizer_t
{
    string m_text;
    this(string text) { m_text = text; }

    override bool parse(string str, ref int cursor)
    {
        if (cursor < str.length)
        {
            writeln(m_text, " -> ", str[cursor]);
        }
        else
        {
            writeln(m_text, "-> EOS");
        }
        return true;
    }

}
class EOL : Tokenizer_t
{
    this()
    {

    }

    override bool parse(string str, ref int cursor)
    {
        //write(" EOL");
        return cursor == str.length;
    }

}

class Or : Tokenizer_t
{
    Tokenizer_t m_a;
    Tokenizer_t m_b;
    this(Tokenizer_t a, Tokenizer_t b)
    {
        m_a = a;
        m_b = b;
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" Or");
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

class Seq : Tokenizer_t
{
    Tokenizer_t[] m_items;
    
    this(Tokenizer_t a, ...)
    {
        m_items ~= a;
        for (int i = 0; i < _arguments.length; i++)
        {
            Tokenizer_t t = va_arg!(Tokenizer_t)(_argptr);
            m_items ~= t;
        }        
    }

    override bool parse(string str, ref int cursor)
    {
        //write(" Seq");

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

