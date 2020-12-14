module puzzles.puzzle14;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism: parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

alias u64 = ulong;

const int MASK = 1;
const int WRITE = 2;

struct memop
{
    int opcode;
    int location;
    u64 value;
};

/// 
void solve_14_1()
{
    auto parser = new InputParser();

    byte[] aopcode;
    u64[]  amemory;
    int[]  alocation;
    u64[]  avalue;
    u64[]  amask1;    // AND
    u64[]  amask2;    // OR

    size_t memory_max = 0;
    readFileLineByLine("input/input_14.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        if (parser.is_match("mem"))
        {
            parser.consume("mem");
            parser.consume("[");
            int l;
            parser.parse(l);
            parser.consume("]");
            parser.consume();
            parser.consume("=");
            parser.consume();
            ulong v;
            parser.parse(v);

            if (l > memory_max)
                memory_max = l;

            aopcode ~= WRITE;
            alocation ~= l;
            avalue ~= v;
            amask1 ~= 0xffffffffffffffff;
            amask2 ~= 0xffffffffffffffff;
        }
        else if (parser.is_match("mask"))
        {
            parser.consume("mask");
            parser.consume();
            parser.consume("=");

            char[] m;
            parser.parse(m);
            u64 m1=0;
            u64 m2=0;
            foreach(c; m)
            {
                if (c == '0')
                {
                    m1 = (m1 << 1) | 0;
                    m2 = (m2 << 1) | 0;
                }
                else if (c == '1')
                {
                    m1 = (m1 << 1) | 0;
                    m2 = (m2 << 1) | 1;
                }
                else if (c == 'X')
                {
                    m1 = (m1 << 1) | 1;
                    m2 = (m2 << 1) | 0;
                }
            }

            aopcode ~= MASK;
            alocation ~= 0;
            avalue ~= 0;
            amask1 ~= m1;
            amask2 ~= m2;
        }
    });
    writeln(memory_max);

    for (int i=0; i<=memory_max; ++i)
        amemory ~= 0;

    u64 mask1 = 0;
    u64 mask2 = 0;
    for (int i=0; i<aopcode.length; ++i)
    {
        if (aopcode[i] == MASK)
        {
            mask1 = amask1[i];
            mask2 = amask2[i];
        }
        else if (aopcode[i] == WRITE)
        {
            u64 value = avalue[i];
            value = (value & mask1) | mask2;
            amemory[alocation[i]] = value;
        }
    }
    u64 sum = 0;
    foreach(m; amemory)
    {
        sum += m;
    }
    writeln("1: Sum of memory = ", sum);
}

u64 constructFloatingMask(u64 mask, int numbits, int perm)
{
    //u64 maskbit = 0x8000000000000000;
    //for (int i=0; i<64; ++i)
    //{
    //    if ((mask & maskbit) == 0)
    //        write('0');
    //    else
    //        write('1');
    //    maskbit = maskbit >> 1;
    //}
//
    //writeln(" : ", numbits, " - ", perm);
    int b = 0;
    u64 maskbit = 1;
    while (b < numbits)
    {
        while ((mask & maskbit) == 0)
            maskbit = maskbit << 1;
        
        int permbit = 1 << b;
        if ((perm & permbit) == 0)
        {
            mask = mask & ~maskbit;
        }

        b += 1;
    }
    return mask;
}

/// 
void solve_14_2()
{
    auto parser = new InputParser();

    byte[] aopcode;
    int[]  alocation;
    u64[]  avalue;
    int[]  amaskfloat_numbits;
    u64[]  amaskfloat;    // FLOATING
    u64[]  amaskor;    // OR

    size_t memory_max = 0;
    readFileLineByLine("input/input_14.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        if (parser.is_match("mem"))
        {
            parser.consume("mem");
            parser.consume("[");
            int l;
            parser.parse(l);
            parser.consume("]");
            parser.consume();
            parser.consume("=");
            parser.consume();
            ulong v;
            parser.parse(v);

            if (l > memory_max)
                memory_max = l;

            aopcode ~= WRITE;
            alocation ~= l;
            avalue ~= v;
            amaskfloat_numbits ~= 0;
            amaskfloat ~= 0xffffffffffffffff;
            amaskor ~= 0xffffffffffffffff;
        }
        else if (parser.is_match("mask"))
        {
            parser.consume("mask");
            parser.consume();
            parser.consume("=");

            char[] m;
            parser.parse(m);
            u64 mf=0;       // float mask
            u64 mo=0;       // or mask
            int mfc = 0;    // float mask bit count
            foreach(c; m)
            {
                if (c == '0')
                {
                    mf = (mf << 1) | 0;
                    mo = (mo << 1) | 0;
                }
                else if (c == '1')
                {
                    mf = (mf << 1) | 0;
                    mo = (mo << 1) | 1;
                }
                else if (c == 'X')
                {
                    mfc += 1;
                    mf = (mf << 1) | 1;
                    mo = (mo << 1) | 0;
                }
            }

            aopcode ~= MASK;
            alocation ~= 0;
            avalue ~= 0;
            amaskfloat_numbits ~= mfc;
            amaskfloat ~= mf;
            amaskor ~= mo;
        }
    });

    u64[u64] amemory;

    int numfloatingbits = 0;
    u64 maskfloat = 0;
    u64 maskor = 0;
    for (int i=0; i<aopcode.length; ++i)
    {
        if (aopcode[i] == MASK)
        {
            numfloatingbits = amaskfloat_numbits[i];
            maskfloat = amaskfloat[i];
            maskor = amaskor[i];
        }
        else if (aopcode[i] == WRITE)
        {
            int permutations = 1 << numfloatingbits;
            for (int perm = 0; perm < permutations; perm+=1)
            {
                u64 memloc = alocation[i] | maskor;
                memloc = memloc & (~maskfloat);
                u64 memlocfloat = constructFloatingMask(maskfloat, numfloatingbits, perm);
                memloc = memloc | memlocfloat;

                amemory[memloc] = avalue[i];
            }
        }
    }
    u64 sum = 0;
    foreach(m; amemory)
    {
        sum += m;
    }
    writeln("2: Sum of memory = ", sum);    
}