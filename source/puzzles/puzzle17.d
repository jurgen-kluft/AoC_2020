module puzzles.puzzle17;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism: parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

const byte INACTIVE = 0;
const byte ACTIVE = 1;

struct cube3_t
{
    int m_cube_size;
    int m_cube_centre_x;
    int m_cube_centre_y;
    int m_cube_centre_z;

    byte[] m_cube;

    void set_size(int size)
    {
        m_cube_size = size;
        m_cube_centre_x = size / 2;
        m_cube_centre_y = size / 2;
        m_cube_centre_z = size / 2;
        m_cube.length = size * size * size;
        clear();
    }

    void set_size_same_as(cube3_t other)
    {
        int size = other.m_cube_size;
        set_size(size);
    }

    void clear()
    {
        for (int i=0; i<m_cube.length; i++)
        {
            m_cube[i] = INACTIVE;
        }
    }

    void copy_from(cube3_t from)
    {
        for (int i=0; i<m_cube.length; i++)
        {
            m_cube[i] = from.m_cube[i];
        }
    }

    int coord_to_index(int x, int y, int z)
    {
        x += m_cube_centre_x;
        y += m_cube_centre_y;
        z += m_cube_centre_z;
        return (z * (m_cube_size * m_cube_size)) + (y * m_cube_size) + x;
    }

    byte getcell(int x, int y, int z)
    {
        int index = coord_to_index(x,y,z);
        return m_cube[index];
    }

    byte setcell(int x, int y, int z, byte b)
    {
        int index = coord_to_index(x,y,z);
        byte old = m_cube[index];
        m_cube[index] = b;
        return old;
    }

    int count_cells(byte state)
    {
        int count = 0;
        for (int i=0; i<m_cube.length; i++)
        {
            if (m_cube[i] == state)
                count += 1;
        }
        return count;
    }

    int count_neighbors(int cx, int cy, int cz, byte state)
    {
        // check the value of the centre so that we do not count it
        int num = 0;
        if (getcell(cx,cy,cz) == state)
            num -= 1;

        for (int x=-1; x<=1; x+=1)
        {
            for (int y=-1; y<=1; y+=1)
            {
                for (int z=-1; z<=1; z+=1)
                {
                    if (getcell(cx+x,cy+y,cz+z) == state)
                    {
                        num += 1;
                    }
                }
            }
        }
        return num;
    }
};


/// 
void solve_17_1()
{
    // 128 * 128 * 128 bytes = 2_097_152 MB
    cube3_t cube;
    cube.set_size(32);
    cube.clear();

    int dim = 0;
    {
        auto parser = new InputParser();
        bool init_size = false;
        int rz = 0;
        int ry = 0;
        readFileLineByLine("input/input_17.text", (string line) {
            parser.reset(line);
            if (line.length == 0)
                return;

            if (!init_size)
            {
                init_size = true;
                dim = cast(int)(line.length / 2);
                ry = -dim;
            }
            
            int rx = -dim;
            foreach(c; line)
            {
                byte state = ACTIVE;
                if (c == '.')
                    state = INACTIVE;
                cube.setcell(rx,ry,rz,state);
                rx += 1;
            }
            ry += 1;
        });
    }

    // If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active.
    //     Otherwise, the cube becomes inactive.
    // If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active.
    //     Otherwise, the cube remains inactive.

    cube3_t dst;
    dst.set_size_same_as(cube);

    int cube_size = dim + 1;
    for (int cycle = 1; cycle <= 6; cycle+=1)
    {
        //writeln("Cycle ", cycle);

        for (int x=-cube_size; x<cube_size; x+=1)
        {
            for (int y=-cube_size; y<cube_size; y+=1)
            {
                for (int z=-cube_size; z<cube_size; z+=1)
                {
                    byte c = cube.getcell(x,y,z);
                    if (c == ACTIVE)
                    {
                        int count = cube.count_neighbors(x,y,z,ACTIVE);
                        if (count == 2 || count == 3)
                        {
                            //writeln("cell (",x,",",y,",",z,") is ACTIVE and stays ACTIVE");
                            // We stay active
                            dst.setcell(x,y,z,ACTIVE);
                        }
                        else
                        {
                            //writeln("cell (",x,",",y,",",z,") is ACTIVE and becomes INACTIVE");
                            // We become inactive
                            dst.setcell(x,y,z,INACTIVE);
                        }
                    }
                    else if (c == INACTIVE)
                    {
                        int count = cube.count_neighbors(x,y,z,ACTIVE);
                        if (count == 3)
                        {
                            //writeln("cell (",x,",",y,",",z,") is INACTIVE and becomes ACTIVE");
                            // We become active
                            dst.setcell(x,y,z,ACTIVE);
                        }
                        else
                        {
                            //writeln("cell (",x,",",y,",",z,") is INACTIVE and stays INACTIVE");
                            // We stay inactive
                            dst.setcell(x,y,z,INACTIVE);
                        }
                    }
                }
            }
        }

        //writeln();

        // Our new ('dst') cube becomes our cube
        cube.copy_from(dst);
        dst.clear();

        // Every cycle the size of the cube is growing by 1
        cube_size += 1;        
    }

    int num_active_cells = cube.count_cells(ACTIVE);
    writeln("1: number of active cells = ", num_active_cells);
}







struct cube4_t
{
    int m_cube_size;
    int m_cube_centre_x;
    int m_cube_centre_y;
    int m_cube_centre_z;
    int m_cube_centre_w;

    byte[] m_cube;

    void set_size(int size)
    {
        m_cube_size = size;
        m_cube_centre_x = size / 2;
        m_cube_centre_y = size / 2;
        m_cube_centre_z = size / 2;
        m_cube_centre_w = size / 2;
        m_cube.length = size * size * size * size;
        clear();
    }

    void set_size_same_as(cube4_t other)
    {
        int size = other.m_cube_size;
        set_size(size);
    }

    void clear()
    {
        for (int i=0; i<m_cube.length; i++)
        {
            m_cube[i] = INACTIVE;
        }
    }

    void copy_from(cube4_t from)
    {
        for (int i=0; i<m_cube.length; i++)
        {
            m_cube[i] = from.m_cube[i];
        }
    }

    int coord_to_index(int x, int y, int z, int w)
    {
        x += m_cube_centre_x;
        y += m_cube_centre_y;
        z += m_cube_centre_z;
        w += m_cube_centre_w;
        return (w * (m_cube_size * m_cube_size * m_cube_size)) + (z * (m_cube_size * m_cube_size)) + (y * m_cube_size) + x;
    }

    byte getcell(int x, int y, int z, int w)
    {
        int index = coord_to_index(x,y,z,w);
        return m_cube[index];
    }

    byte setcell(int x, int y, int z, int w, byte b)
    {
        int index = coord_to_index(x,y,z,w);
        byte old = m_cube[index];
        m_cube[index] = b;
        return old;
    }

    int count_cells(byte state)
    {
        int count = 0;
        for (int i=0; i<m_cube.length; i++)
        {
            if (m_cube[i] == state)
                count += 1;
        }
        return count;
    }

    int count_neighbors(int cx, int cy, int cz, int cw, byte state)
    {
        // check the value of the centre so that we do not count it
        int num = 0;
        if (getcell(cx,cy,cz,cw) == state)
            num -= 1;

        for (int x=-1; x<=1; x+=1)
        {
            for (int y=-1; y<=1; y+=1)
            {
                for (int z=-1; z<=1; z+=1)
                {
                    for (int w=-1; w<=1; w+=1)
                    {
                        if (getcell(cx+x,cy+y,cz+z,cw+w) == state)
                        {
                            num += 1;
                        }
                    }
                }
            }
        }
        return num;
    }
};

/// 
void solve_17_2()
{
    cube4_t cube;
    cube.set_size(32);
    cube.clear();

    int dim = 0;
    {
        auto parser = new InputParser();
        bool init_size = false;
        int rw = 0;
        int rz = 0;
        int ry = 0;
        readFileLineByLine("input/input_17.text", (string line) {
            parser.reset(line);
            if (line.length == 0)
                return;

            if (!init_size)
            {
                init_size = true;
                dim = cast(int)(line.length / 2);
                ry = -dim;
            }
            
            int rx = -dim;
            foreach(c; line)
            {
                byte state = ACTIVE;
                if (c == '.')
                    state = INACTIVE;
                cube.setcell(rx,ry,rz,rw,state);
                rx += 1;
            }
            ry += 1;
        });
    }

    // If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active.
    //     Otherwise, the cube becomes inactive.
    // If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active.
    //     Otherwise, the cube remains inactive.

    cube4_t dst;
    dst.set_size_same_as(cube);

    int cube_size = dim + 1;
    for (int cycle = 1; cycle <= 6; cycle+=1)
    {
        //writeln("Cycle ", cycle);

        for (int x=-cube_size; x<cube_size; x+=1)
        {
            for (int y=-cube_size; y<cube_size; y+=1)
            {
                for (int z=-cube_size; z<cube_size; z+=1)
                {
                    for (int w=-cube_size; w<cube_size; w+=1)
                    {
                        byte c = cube.getcell(x,y,z,w);
                        if (c == ACTIVE)
                        {
                            int count = cube.count_neighbors(x,y,z,w,ACTIVE);
                            if (count == 2 || count == 3)
                            {
                                //writeln("cell (",x,",",y,",",z,") is ACTIVE and stays ACTIVE");
                                // We stay active
                                dst.setcell(x,y,z,w,ACTIVE);
                            }
                            else
                            {
                                //writeln("cell (",x,",",y,",",z,") is ACTIVE and becomes INACTIVE");
                                // We become inactive
                                dst.setcell(x,y,z,w,INACTIVE);
                            }
                        }
                        else if (c == INACTIVE)
                        {
                            int count = cube.count_neighbors(x,y,z,w,ACTIVE);
                            if (count == 3)
                            {
                                //writeln("cell (",x,",",y,",",z,") is INACTIVE and becomes ACTIVE");
                                // We become active
                                dst.setcell(x,y,z,w,ACTIVE);
                            }
                            else
                            {
                                //writeln("cell (",x,",",y,",",z,") is INACTIVE and stays INACTIVE");
                                // We stay inactive
                                dst.setcell(x,y,z,w,INACTIVE);
                            }
                        }
                    }
                }
            }
        }

        //writeln();

        // Our new ('dst') cube becomes our cube
        cube.copy_from(dst);
        dst.clear();

        // Every cycle the size of the cube is growing by 1
        cube_size += 1;        
    }

    int num_active_cells = cube.count_cells(ACTIVE);
    writeln("2: number of active cells = ", num_active_cells);
}
