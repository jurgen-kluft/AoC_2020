module puzzles.puzzle8;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;

const int opcode_nop = 0;
const int opcode_jmp = 1;
const int opcode_acc = 2;

struct instruction
{
    int m_opcode;
    int m_operand;
}

/// 
void solve_8_1()
{
    instruction[] program;

    auto parser = new InputParser();
    readFileLineByLine("input/input_8.text", (string line) {
        parser.reset(line);

        string operation;
        parser.readWord(operation);
        int operand;
        parser.parse(operand);

        instruction codeline;
        if (operation == "acc")
        {
            codeline.m_opcode = opcode_acc;
            codeline.m_operand = operand;
        }
        else if (operation == "jmp")
        {
            codeline.m_opcode = opcode_jmp;
            codeline.m_operand = operand;
        }
        else if (operation == "nop")
        {
            codeline.m_opcode = opcode_nop;
            codeline.m_operand = 0;
        }

        program ~= codeline;
    });

    // Execute program
    bool[] executed;
    executed.length = program.length;
    for (int i=0; i<program.length; i++)
        executed[i] = false;

    int acc = 0;
    int pc = 0;
    while (executed[pc] == false)
    {
        executed[pc] = true;
        if (program[pc].m_opcode == opcode_jmp)
        {
            //writeln("pc=", pc, " -> jmp ", program[pc].m_operand);
            pc = pc + program[pc].m_operand;
        }
        else if (program[pc].m_opcode == opcode_acc)
        {
            //writeln("pc=", pc, " -> acc ", program[pc].m_operand);
            acc += program[pc].m_operand;
            pc = pc + 1;
        }
        else if (program[pc].m_opcode == opcode_nop)
        {
            //writeln("pc=", pc, " -> nop");
            pc = pc + 1;
        }
    }
    writeln("1: acc = ", acc);
}

/// 
void solve_8_2()
{
    instruction[] program;

    auto parser = new InputParser();
    readFileLineByLine("input/input_8.text", (string line) {
        parser.reset(line);

        string operation;
        parser.readWord(operation);
        int operand;
        parser.parse(operand);

        instruction codeline;
        if (operation == "acc")
        {
            codeline.m_opcode = opcode_acc;
            codeline.m_operand = operand;
        }
        else if (operation == "jmp")
        {
            codeline.m_opcode = opcode_jmp;
            codeline.m_operand = operand;
        }
        else if (operation == "nop")
        {
            codeline.m_opcode = opcode_nop;
            codeline.m_operand = 0;
        }

        program ~= codeline;
    });

    // Execute program
    bool[] executed;
    executed.length = program.length;

    int pc_fix = 0;
    bool fixed = false;
    while (!fixed)
    {
        for (int i=0; i<program.length; i++)
            executed[i] = false;

        while (program[pc_fix].m_opcode == opcode_acc)
        {
            pc_fix += 1;
        }

        // Try and fix the program
        if (program[pc_fix].m_opcode == opcode_jmp)
        {
            program[pc_fix].m_opcode = opcode_nop;
        }
        else if (program[pc_fix].m_opcode == opcode_nop)
        {
            program[pc_fix].m_opcode = opcode_jmp;
        }

        int acc = 0;
        int pc = 0;

        while (pc < program.length && executed[pc] == false)
        {
            executed[pc] = true;
            if (program[pc].m_opcode == opcode_jmp)
            {
                //writeln("pc=", pc, " -> jmp ", program[pc].m_operand);
                pc = pc + program[pc].m_operand;
            }
            else if (program[pc].m_opcode == opcode_acc)
            {
                //writeln("pc=", pc, " -> acc ", program[pc].m_operand);
                acc += program[pc].m_operand;
                pc = pc + 1;
            }
            else if (program[pc].m_opcode == opcode_nop)
            {
                //writeln("pc=", pc, " -> nop");
                pc = pc + 1;
            }
        }

        // Revert the program change
        if (program[pc_fix].m_opcode == opcode_jmp)
        {
            program[pc_fix].m_opcode = opcode_nop;
        }
        else if (program[pc_fix].m_opcode == opcode_nop)
        {
            program[pc_fix].m_opcode = opcode_jmp;
        }

        // Next instruction to fix
        pc_fix += 1;

        if (pc == program.length)
        {
            writeln("2: fix count = ", pc_fix, " - ", "acc = ", acc);
            fixed = true;
        }
    }
}
