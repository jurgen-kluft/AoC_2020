module puzzles.puzzle7;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import core.stdc.string : strlen;
import utilities.inputparser;


struct bag
{
    int index;
    int[] parents;
    int[] child_count;
    int[] child_index;
}

struct bagiter
{
    bool[] visited;
    int[] stack;
}

int indexOf(string[] array, string w)
{
    for (int i=0; i<array.length; ++i)
    {
        if (array[i] == w)
            return i;
    }
    return -1;
}

/// 
void solve_7_1()
{
    string[] bag_names = [];
    bag[] bags = [];
    bag emptybag;

    auto parser = new InputParser();
    readFileLineByLine("input/input_7.text", (string line) {
        parser.reset(line);
        
        if (!parser.at_end())
        {
            string bagname_first;
            string bagname_last;

            parser.readWord(bagname_first);
            parser.readWord(bagname_last);
            string bagname = (bagname_first ~ " " ~ bagname_last);

            int parentindex = indexOf(bag_names, bagname);
            if (parentindex < 0)
            {
                parentindex = cast(int)bag_names.length;
                bag_names ~= bagname;
                bags ~= emptybag;
                bags[parentindex].index = parentindex;
            }

            parser.consume("bags");
            parser.consume("bag");
            parser.consume("contain");

            char separator = ',';
            while (separator == ',' && !parser.at_end())
            {
                int child_count;
                parser.parse(child_count);

                bagname_first = "";
                bagname_last = "";
                parser.readWord(bagname_first);
                parser.readWord(bagname_last);

                parser.consume("bags");
                parser.consume("bag");

                bag child;
                bagname = (bagname_first ~ " " ~ bagname_last);
                int child_index = indexOf(bag_names, bagname);
                if (child_index < 0)
                {
                    child_index = cast(int)bag_names.length;
                    bag_names ~= bagname;
                    bags ~= emptybag;
                    bags[child_index].index = child_index;
                }

                bags[child_index].parents ~= parentindex;
                bags[parentindex].child_count ~= child_count;
                bags[parentindex].child_index ~= child_index;

                parser.read(separator);
            }
        }
    });

    // foreach(bag; bags)
    // {
    //     write(bag_names[bag.index]);
    //     foreach(i, child; bag.child_index.enumerate(0))
    //     {
    //         write("; ", bag.child_count[i], " of ", bag_names[child]);
    //     }
    //     writeln();
    // }

    // foreach(bagname; bag_names)
    // {
    //     writeln(bagname);
    // }

    // We need to figure out all of the parents of "shiny gold"
    bagiter iter;
    iter.visited.length = bag_names.length;

    string nameOfBagToFindParentsFor = "shiny gold";
    int indexOfBagToFindParentsFor = indexOf(bag_names, nameOfBagToFindParentsFor);
    int numBagsThatCanHoldTheOneToFind = 0;
    
    for (int i = 0; i<bags.length; ++i)
    {
        for (int j=0; j<iter.visited.length; ++j)
            iter.visited[j] = false;

        iter.stack = [];
        iter.stack ~= i;

        checkAllChildren: while (iter.stack.length > 0)
        {
            int bagIndex = iter.stack.back;
            iter.stack.popBack();

            if (iter.visited[bagIndex] == false)
            {
                // Push all children onto the stack since we need to visit them
                // Do check if we have visited them
                foreach(child; bags[bagIndex].child_index)
                {
                    if (iter.visited[child] == false)
                    {
                        if (child == indexOfBagToFindParentsFor)
                        {
                            //writeln(bag_names[i], " can hold a ", nameOfBagToFindParentsFor);
                            numBagsThatCanHoldTheOneToFind += 1;
                            break checkAllChildren;
                        }
                        iter.stack ~= child;
                    }
                }
                iter.visited[bagIndex] = true;
            }
        }
    }

    writeln("1: Number of parents that can hold ", nameOfBagToFindParentsFor, " = ", numBagsThatCanHoldTheOneToFind);
}

/// 
void solve_7_2()
{
    string[] bag_names = [];
    bag[] bags = [];
    bag emptybag;

    auto parser = new InputParser();
    readFileLineByLine("input/input_7.text", (string line) {
        parser.reset(line);
        
        if (!parser.at_end())
        {
            string bagname_first;
            string bagname_last;

            parser.readWord(bagname_first);
            parser.readWord(bagname_last);
            string bagname = (bagname_first ~ " " ~ bagname_last);

            int parentindex = indexOf(bag_names, bagname);
            if (parentindex < 0)
            {
                parentindex = cast(int)bag_names.length;
                bag_names ~= bagname;
                bags ~= emptybag;
                bags[parentindex].index = parentindex;
            }

            parser.consume("bags");
            parser.consume("bag");
            parser.consume("contain");

            char separator = ',';
            while (separator == ',' && !parser.at_end())
            {
                int child_count;
                parser.parse(child_count);

                bagname_first = "";
                bagname_last = "";
                parser.readWord(bagname_first);
                parser.readWord(bagname_last);

                parser.consume("bags");
                parser.consume("bag");

                bag child;
                bagname = (bagname_first ~ " " ~ bagname_last);
                int child_index = indexOf(bag_names, bagname);
                if (child_index < 0)
                {
                    child_index = cast(int)bag_names.length;
                    bag_names ~= bagname;
                    bags ~= emptybag;
                    bags[child_index].index = child_index;
                }

                bags[child_index].parents ~= parentindex;
                bags[parentindex].child_count ~= child_count;
                bags[parentindex].child_index ~= child_index;

                parser.read(separator);
            }
        }
    });

    // foreach(bag; bags)
    // {
    //     write(bag_names[bag.index]);
    //     foreach(i, child; bag.child_index.enumerate(0))
    //     {
    //         write("; ", bag.child_count[i], " of ", bag_names[child]);
    //     }
    //     writeln();
    // }

    // foreach(bagname; bag_names)
    // {
    //     writeln(bagname);
    // }

    // We need to figure out all of the parents of "shiny gold"
    bagiter iter;
    iter.visited.length = bag_names.length;

    string nameOfBagToFindChildrenFor = "shiny gold";
    int indexOfBagToFindChildsFor = indexOf(bag_names, nameOfBagToFindChildrenFor);
    int numBagsThatAreHoldByTheOne = 0;
    
    {
        for (int j=0; j<iter.visited.length; ++j)
            iter.visited[j] = false;

        iter.stack = [];
        {
            int bagIndex = indexOfBagToFindChildsFor;
            foreach(childIndex, childCount; zip(bags[bagIndex].child_index, bags[bagIndex].child_count))
            {
                for (int c=0; c<childCount; c++)
                    iter.stack ~= childIndex;
            }            
        }
        

        while (iter.stack.length > 0)
        {
            int bagIndex = iter.stack.back;
            iter.stack.popBack();
            numBagsThatAreHoldByTheOne += 1;
            {
                // Push all children onto the stack since we need to visit them
                foreach(childIndex, childCount; zip(bags[bagIndex].child_index, bags[bagIndex].child_count))
                {
                    //writeln(bag_names[iindexOfBagToFindChildsFor], " can hold a ", nameOfBagToFindChildrenFor);
                    for (int c=0; c<childCount; c++)
                        iter.stack ~= childIndex;
                }            
            }
        }
    }

    writeln("2: Number of bags contained in 1 ", nameOfBagToFindChildrenFor, " = ", numBagsThatAreHoldByTheOne);
}
