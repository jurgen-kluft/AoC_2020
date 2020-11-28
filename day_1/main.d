import std.conv, std.string, std.range, std.stdio, std.format;
// Read lines using foreach.
void main()
{
    auto file = File("input.text");
    auto range = file.byLine();
    foreach (line; range)
    {
        int[2] p,v;
        string s = to!string(line);
        string pos, vel;
        s.formattedRead!"position=<%s> velocity=<%s>"(pos,vel);
        string[] pos_dims = split(pos, ",");
        int i = 0;
        foreach (dim; pos_dims) {
            auto value = strip(dim).to!int;
            p[i++] = value;
        }
        string[] vel_dims = split(vel, ",");
        i = 0;
        foreach (dim; vel_dims) {
            auto value = strip(dim).to!int;
            v[i++] = value;
        }
        writeln(p,v);
        if (!line.empty)
            writeln(line);
    }
}
