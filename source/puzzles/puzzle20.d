module puzzles.puzzle20;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism : parallel;
import core.stdc.string : strlen;

import utilities.inputparser;
import parser = utilities.parser2;

alias s16 = short;
alias s8 = byte;

const s16 TOP = 0;
const s16 RIGHT = 1;
const s16 BOTTOM = 2;
const s16 LEFT = 3;

const s8 WHITE_PIXEL = 0;
const s8 BLACK_PIXEL = 1;

class Tile
{
    this()
    {
        TID = -1;
        for (int r=0; r<10; r++)
        {
            for (int c=0; c<10; c++)
            {
                Image[r*10 + c] = WHITE_PIXEL;
            }
        }
        ResetConnections();
    }

    void ResetConnections()
    {
        ConnectingTiles[TOP]=-1;
        ConnectingTiles[RIGHT]=-1;
        ConnectingTiles[BOTTOM]=-1;
        ConnectingTiles[LEFT]=-1;
    }

    s16 FindConnectingSideFor(s16 other_tile_index)
    {
        foreach (i; 0 .. 4)
        {
            if (ConnectingTiles[i] == other_tile_index)
                return cast(s16)i;
        }
        return -1;
    }

    s16 TID;
    s8[10 * 10] Image;
    s16[4] ConnectingTiles;
}

s16 TileCountConnectingSides(Tile tile)
{
    s16 count = 0;
    foreach (i; 0 .. 4)
    {
        if (tile.ConnectingTiles[i] >= 0)
            count += 1;
    }
    return count;
}

s16 TileGetTopSideBits(Tile tile)
{
    s16 side = 0;
    foreach(i; 0..10)
    {
        s8 pixel = tile.Image[i];
        side <<= 1;
        if (pixel != 0)
            side |= 1;
    }
    return side;
}
s16 TileGetBottomSideBits(Tile tile)
{
    s16 side = 0;
    foreach(i; 90 .. 100)
    {
        s8 pixel = tile.Image[i];
        side >>= 1;
        if (pixel != 0)
            side |= 0x200;
    }
    return side;
}
s16 TileGetRightSideBits(Tile tile)
{
    s16 side = 0;
    foreach (i; 0 .. 10)
    {
        side <<= 1;
        if (tile.Image[i*10 + 9] != 0)
            side |= 1;
    }
    return side;
}
s16 TileGetLeftSideBits(Tile tile)
{
    s16 side = 0;
    foreach (i; 0 .. 10)
    {
        side >>= 1;
        if (tile.Image[i*10 + 0] != 0)
            side |= 0x200;
    }
    return side;
}

s16 TileGetConnectingTileFromSide(Tile tile, s16 side_index)
{
    return tile.ConnectingTiles[side_index];
}

s16 MirrorSideBits(s16 side)
{
    s16 res = 0;
    if ((side & 0x001))res |= 0x200;
    if ((side & 0x002))res |= 0x100;
    if ((side & 0x004))res |= 0x080;
    if ((side & 0x008))res |= 0x040;
    if ((side & 0x010))res |= 0x020;
    if ((side & 0x020))res |= 0x010;
    if ((side & 0x040))res |= 0x008;
    if ((side & 0x080))res |= 0x004;
    if ((side & 0x100))res |= 0x002;
    if ((side & 0x200))res |= 0x001;
    return res;
}

void NormalTileGetEverySideBits(Tile tile, ref s16[4] sides_bits)
{
    sides_bits[0] = TileGetTopSideBits(tile);
    sides_bits[1] = TileGetRightSideBits(tile);
    sides_bits[2] = TileGetBottomSideBits(tile);
    sides_bits[3] = TileGetLeftSideBits(tile);
}
void FlippedTileGetEverySideBits(Tile tile, ref s16[4] sides_bits)
{
    NormalTileGetEverySideBits(tile, sides_bits);
    s16 side1 = sides_bits[1];
    s16 side3 = sides_bits[3];
    sides_bits[0] = MirrorSideBits(sides_bits[0]);
    sides_bits[1] = MirrorSideBits(side3);
    sides_bits[2] = MirrorSideBits(sides_bits[2]);
    sides_bits[3] = MirrorSideBits(side1);
}

s16 TileGetSideBits(Tile tile, s8 edge)
{
    switch (edge)
    {
        case 0: return TileGetTopSideBits(tile);
        case 1: return TileGetRightSideBits(tile);
        case 2: return TileGetBottomSideBits(tile);
        case 3: return TileGetLeftSideBits(tile);
        default: assert(false);
    }
}

bool TileHasConnections(Tile tile, bool top, bool right, bool bottom, bool left)
{
    return (!top || tile.ConnectingTiles[0] >= 0) 
            && (!right || tile.ConnectingTiles[1] >= 0)
                && (!bottom || tile.ConnectingTiles[2] >= 0)
                    && (!left || tile.ConnectingTiles[3] >= 0);
}

void TileRotateCW(Tile tile, ref s8[10*10] work)
{
    // Rotate Clock-Wise:
    //   -> Top becomes Right
    //   -> Right becomes Bottom
    //   -> Bottom becomes Left
    //   -> Left becomes Top
    s16 ct0 = tile.ConnectingTiles[0];
    tile.ConnectingTiles[0] = tile.ConnectingTiles[3];
    tile.ConnectingTiles[3] = tile.ConnectingTiles[2];
    tile.ConnectingTiles[2] = tile.ConnectingTiles[1];
    tile.ConnectingTiles[1] = ct0;

    for (int r=0; r<work.length; r++)
    {
        work[r] = tile.Image[r];
    }

    for (int r=0; r<10; r++)
    {
        for (int c=0; c<10; c++)
        {
            tile.Image[c*10 + (9-r)] = work[r*10 + c];
        }
    }
}

void TileFlipHorizontally(Tile tile)
{
    // Flip Horizontally 
    //  ---
    //  / \
    //   |
    //  ---
    //   |
    //  \ /
    //  ---
    s16 ct0 = tile.ConnectingTiles[0];
    tile.ConnectingTiles[0] = tile.ConnectingTiles[2];
    tile.ConnectingTiles[2] = ct0;
    for (int r=4; r>=0; r-=1)
    {
        for (int c=0; c<10; c+=1)
        {
            s8 bt = tile.Image[r*10 + c];
            s8 bb = tile.Image[(9-r)*10 + c];
            tile.Image[r*10 + c] = bb;
            tile.Image[(9-r)*10 + c] = bt;
        }
    }
}

void TileFlipVertically(Tile tile)
{
    // Flip Vertically
    //
    // < ---|---  >
    //

    s16 ct1 = tile.ConnectingTiles[1];
    tile.ConnectingTiles[1] = tile.ConnectingTiles[3];
    tile.ConnectingTiles[3] = ct1;
    for (int r=0; r<10; r++)
    {
        for (int c=4; c>=0; c--)
        {
            s8 bl = tile.Image[r*10 + c];
            s8 br = tile.Image[r*10 +(9-c)];
            tile.Image[r*10 + c] = br;
            tile.Image[r*10 + (9-c)] = bl;
        }
    }
}

void PrintSideBits(s16 side)
{
    foreach (i; 0 .. 10)
    {
        if (side & 0x200)
            write('#');
        else
            write('.');
        side <<= 1;
    }
}

void PrintTile(Tile tile)
{
    writeln("Tile: ", tile.TID);
    writeln("  ");
    s16[4] sides_bits;
    NormalTileGetEverySideBits(tile, sides_bits);
    write("Normal : ");
    PrintSideBits(sides_bits[0]); write('\\');
    PrintSideBits(sides_bits[1]); write('\\');
    PrintSideBits(sides_bits[2]); write('\\');
    PrintSideBits(sides_bits[3]);
    writeln();
    write("Flipped: ");
    FlippedTileGetEverySideBits(tile, sides_bits);
    PrintSideBits(sides_bits[0]); write('\\');
    PrintSideBits(sides_bits[1]); write('\\');
    PrintSideBits(sides_bits[2]); write('\\');
    PrintSideBits(sides_bits[3]);
    writeln();

    foreach (r; 0..10)
    {
        write("  ");
        foreach(c; 0..10)
        {
            s8 pixel = tile.Image[r*10 + c];
            if (pixel == 0)
                write('.');
            else
                write('#');
        }
        writeln();
    }
    writeln();
}

void BoardRotateCW(ref s16[12*12] board, ref s16[12*12] scratch)
{
    const int W = 12;
    const int H = 12;

    for (int r=0; r<board.length; r++)
    {
        scratch[r] = board[r];
    }

    for (int r=0; r<H; r++)
    {
        for (int c=0; c<W; c++)
        {
            board[c*W + (H-r-1)] = scratch[r*W + c];
        }
    }
}

void PrintBoard(const ref s16[12*12] board, Tile[] all_tiles)
{
    for (int r=0; r<12; r++)
    {
        write("+");
        for (int i=0;i<12;i++)
        {
            if (i > 0)
                write('+');
            write("------");
        }
        writeln("+");

        for (int c=0; c<12; c++)
        {
            if (c == 0)
                write("| ");
            else
                write(" | ");
            s16 tile_index = board[r*12 + c];
            write(all_tiles[tile_index].TID);
        }
        writeln(" |");
    }

    write("+");
    for (int i=0;i<12;i++)
    {
        if (i > 0)
            write('+');
        write("------");
    }
    writeln("+");
    writeln();
}

void WriteTileImageToImage(ref s8[96*96] image, const Tile tile, int ir, int ic)
{
    // Skip the edges of the Tile image, only write the inner pixels to the final image
    // So only a 8x8 tile image
    for (int r=0; r<8; r++)
    {
        for (int c=0; c<8; c++)
        {
            image[(ir+r)*96 + ic+c] = tile.Image[(1+r)*10 + (1+c)];
        }
    }
}

void ConstructImageFromBoard(const ref s16[12*12] board, const ref Tile[] tiles, ref s8[96*96] image)
{
    const int W = 12;
    const int H = 12;

    for (int r=0; r<H; r++)
    {
        for (int c=0; c<W; c++)
        {
            s16 tile_index = board[r*W + c];
            const Tile tile = tiles[tile_index];
            WriteTileImageToImage(image, tile, r * 8, c * 8);
        }
    }
}

void ImageRotateCW(ref s8[96*96] image, ref s8[96*96] scratch)
{
    const int W = 96;
    const int H = 96;

    for (int r=0; r<image.length; r++)
    {
        scratch[r] = image[r];
    }

    for (int r=0; r<H; r++)
    {
        for (int c=0; c<W; c++)
        {
            image[c*W + (H-r-1)] = scratch[r*W + c];
        }
    }
}

bool ImageMatchSubImage(const ref s8[96*96] image, const ref s8[3*20] subimage, int ir, int ic)
{
    for (int sr=0; sr<3; sr++)
    {
        for (int sc=0; sc<20; sc++)
        {
            if (subimage[sr*20 + sc] == 1)
            {
                if (image[(ir+sr)*96 + ic+sc] != 1)
                {
                    return false;
                }
            }
        }
    }
    return true;
}

void ImageMaskSubImage(ref s8[96*96] image, const ref s8[3*20] subimage, int ir, int ic)
{
    for (int sr=0; sr<3; sr++)
    {
        for (int sc=0; sc<20; sc++)
        {
            if (subimage[sr*20 + sc] == 1)
            {
                image[(ir+sr)*96 + ic+sc] = WHITE_PIXEL;
            }
        }
    }
}


void PrintImage(const ref s8[96*96] image)
{
    for (int r=0; r<96; r++)
    {
        for (int c=0; c<96; c++)
        {
            if (image[r*96 + c] == 0)
                write(' ');
            else
                write('o');
        }
        writeln();
    }
    writeln();
    writeln();
}

/// 
void solve_20_1()
{
    // Tile 3583:
    // .##..#..#.
    // ....##....
    // ##..#..#..
    // .....#....
    // .#..#.....
    // #.#.......
    // #.....#..#
    // ....#....#
    // ...#.##.#.
    // .#....##.#

    // Puzzle is a 12 x 12 board
    
    string[] lines;
    readFileLineByLine("input/input_20.text", (string line) {
        lines ~= line;
    });

    parser.Var tileIndexVar = new parser.Var();
    parser.Seq tileHeader = new parser.Seq(
        new parser.Exact("Tile"),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.Index(tileIndexVar),
        new parser.Is(':'),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.EOL()
    );

    Tile[] all_tiles;
    for (int i=0; i<lines.length; i+=1)
    {
        string header = lines[i++];
        int cursor = 0;
        if (tileHeader.parse(header, cursor))
        {
            Tile tile = new Tile();
            tile.TID = cast(s16)tileIndexVar.Get();
            int r = 0;
            while (lines[i].length > 0)
            {
                int c = 0;
                foreach(ch; lines[i])
                {
                    tile.Image[r*10 + c] = (ch == '#') ? BLACK_PIXEL : WHITE_PIXEL;
                    c += 1;
                }
                i += 1;
                r += 1;
            }
            all_tiles ~= tile;
        }
    }

    //foreach(tile; all_tiles)
    //{
    //    PrintTile(tile);
    //}
    //PrintTile(all_tiles[0]);

    // Analyze, if we just add all sides_bits to a map, are there any Tiles
    // that only have 2 sides_bits that can connect? Those should be the
    // corner pieces.
    int[s16] edge_connections;
    s16[4] sides_bits;
    int[4] edges;
    foreach(tile; all_tiles)
    {
        NormalTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
            edge_connections[sides_bits[i]] += 1;
        FlippedTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
            edge_connections[sides_bits[i]] += 1;
    }

    int[] corner_pieces;
    // Now check the connections for each tile
    foreach(index, tile; all_tiles)
    {
        // First remove ourselves
        NormalTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
            edge_connections[sides_bits[i]] -= 1;
        FlippedTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
            edge_connections[sides_bits[i]] -= 1;

        int num_edges_that_can_connect = 0;
        foreach (i; 0 .. 4)
            edges[i] = 0;

        NormalTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
        {
            edges[i] = edge_connections[sides_bits[i]];
            if (edges[i] > 0)
                num_edges_that_can_connect+=1;
        }
        if (num_edges_that_can_connect == 2)
        {
            // writeln("Tile ", tile.TID, " !rotated is a corner piece!");
            corner_pieces ~= cast(int)index;
        }
        else
        {
            //writeln("Tile ", tile.TID, " !rotated can have ", num_edges_that_can_connect, " connections");
        }

        num_edges_that_can_connect = 0;
        foreach (i; 0 .. 4)
            edges[i] = 0;

        FlippedTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
        {
            edges[i] = edge_connections[sides_bits[i]];
            if (edges[i] > 0)
                num_edges_that_can_connect+=1;
        }

        if (num_edges_that_can_connect == 2)
        {
            //writeln("Tile ", tile.TID, " rotated is a corner piece!");
        }
        else
        {
            //writeln("Tile ", tile.TID, " rotated can have ", num_edges_that_can_connect, " connections");
        }

        // Add ourselves back
        NormalTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
            edge_connections[sides_bits[i]] += 1;
        FlippedTileGetEverySideBits(tile, sides_bits);
        foreach (i; 0 .. 4)
            edge_connections[sides_bits[i]] += 1;
    }

    long result = 1;
    foreach(tileIndex; corner_pieces)
    {
        result *= all_tiles[tileIndex].TID;
    }

    writeln("1: result = ", result);
    writeln();
    writeln();
}

/// 
void solve_20_2()
{
    string[] lines;
    readFileLineByLine("input/input_20.text", (string line) {
        lines ~= line;
    });

    parser.Var tileIndexVar = new parser.Var();
    parser.Seq tileHeader = new parser.Seq(
        new parser.Exact("Tile"),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.Index(tileIndexVar),
        new parser.Is(':'),
        new parser.ZeroOrMore(new parser.Whitespace()),
        new parser.EOL()
    );


    Tile[] all_tiles;
    for (int i=0; i<lines.length; i+=1)
    {
        string header = lines[i++];
        int cursor = 0;
        if (tileHeader.parse(header, cursor))
        {
            Tile tile = new Tile();
            tile.TID = cast(s16)tileIndexVar.Get();
            int r = 0;
            while (lines[i].length > 0)
            {
                int c = 0;
                foreach(ch; lines[i])
                {
                    tile.Image[r*10 + c] = (ch == '#') ? BLACK_PIXEL : WHITE_PIXEL;
                    c += 1;
                }
                i += 1;
                r += 1;
            }
            all_tiles ~= tile;
        }
    }

    s16[s16] side_to_tile;
    s16[4] sides_bits;
    foreach(current_tile_index, current_tile; all_tiles)
    {
        foreach (i; 0 .. 2)
        {
            if (i == 0) NormalTileGetEverySideBits(current_tile, sides_bits);
            if (i == 1) FlippedTileGetEverySideBits(current_tile, sides_bits);
            foreach (side_index; 0 .. 4)
            {
                s16 side_bits = sides_bits[side_index];
                if ((side_bits in side_to_tile) == null)
                {
                    side_to_tile[side_bits] = cast(s16)current_tile_index;
                }
                else
                {
                    side_to_tile[0x1000 | side_bits] = cast(s16)current_tile_index;
                }
            }
        }
    }

    s16 GetOtherTile(ref s16[s16] side_to_tile, s16 current_tile_index, s16 current_side_bits)
    {
        s16 connecting_tile_index = -1;

        s16 connecting_tile_index_1 = -1;
        if ((current_side_bits in side_to_tile) != null)
            connecting_tile_index_1 = side_to_tile[current_side_bits];

        s16 connecting_tile_index_2 = -1;
        if (((current_side_bits | 0x1000) in side_to_tile) != null)
            connecting_tile_index_2 = side_to_tile[current_side_bits | 0x1000];
            
        if (connecting_tile_index_1 != current_tile_index)
        {
            connecting_tile_index = connecting_tile_index_1;
        }
        else if (connecting_tile_index_2 != current_tile_index)
        {
            connecting_tile_index = connecting_tile_index_2;
        }
        return connecting_tile_index;
    }

    // For every tile connect each side to another tile
    foreach(current_tile_index, current_tile; all_tiles)
    {
        NormalTileGetEverySideBits(current_tile, sides_bits);
        foreach (current_tile_side_index; 0 .. 4)
        {
            s16 current_tile_side_bits = sides_bits[current_tile_side_index];
            s16 other_tile_index = GetOtherTile(side_to_tile, cast(s16)current_tile_index, current_tile_side_bits);
            current_tile.ConnectingTiles[current_tile_side_index] = other_tile_index;
        }
    }

    // Pick a corner as a starting tile
    s16 start_tile_index = -1;
    foreach(current_tile_index, current_tile; all_tiles)
    {
        s16 num_sides_connected = TileCountConnectingSides(current_tile);
        if (num_sides_connected == 2)
        {
            writeln("Tile ", current_tile.TID, " is a corner");
            if (start_tile_index == -1)
                start_tile_index = cast(s16)current_tile_index;
        }
        else
        {
            //writeln("Tile ", current_tile.TID, " has ", num_sides_connected, " sides connected");
        }
    }

    // Rotate starting tile until we have a Right/Down connecting edge
    s8[10*10] work;
    writeln("2: Rotating starting Tile ", all_tiles[start_tile_index].TID, " until it has only Right/Down connections (Left-Upper corner)");
    while (!TileHasConnections(all_tiles[start_tile_index], false, true, true, false))
    {
        // Rotate
        TileRotateCW(all_tiles[start_tile_index], work);
    }

    writeln("2: Organize 12x12 board holding all the tiles");

    // Organize the board, we know the top-left corner and we start to fill up the board from there.
    s16[12*12] board;
    board[0] = start_tile_index;
    for (int r=0; r<12; r++)
    {
        for (int c=0; c<12; c++)
        {
            if (r == 0)
            {
                // First row we just go RIGHT
                s16 current_tile_index = board[r*12 + c];
                Tile current_tile = all_tiles[current_tile_index];

                // The tile is fully correct when TOP connecting tile index is -1, 
                // if not we need to flip it Horizontally!
                if (TileGetConnectingTileFromSide(current_tile, TOP) != -1)
                {
                    TileFlipHorizontally(current_tile);
                }

                if (c < 11)
                {
                    s16 right_tile_index = TileGetConnectingTileFromSide(current_tile, RIGHT);
                    board[r*12 + (c+1)] = right_tile_index;
                    Tile right_tile = all_tiles[right_tile_index];
                    // Rotate right tile until it's LEFT connecting tile is the current tile index
                    while (TileGetConnectingTileFromSide(right_tile, LEFT) != current_tile_index)
                    {
                        TileRotateCW(right_tile, work);
                    }
                }
            }
            else
            {
                // Here, from the row above we use the tile and get it's BOTTOM connecting tile 
                s16 top_tile_index = board[(r-1)*12 + c];
                Tile top_tile = all_tiles[top_tile_index];
                s16 current_tile_index = TileGetConnectingTileFromSide(top_tile, BOTTOM);
                Tile current_tile = all_tiles[current_tile_index];

                // Rotate current tile until the TOP connecting tile index is correct
                while (TileGetConnectingTileFromSide(current_tile, TOP) != top_tile_index)
                {
                    TileRotateCW(current_tile, work);
                }

                // Check if we need to horizontally flip the current tile
                if (c == 0)
                {
                    // If we are the first tile in the row we need to make sure our
                    // LEFT connecting tile is -1.
                    if (TileGetConnectingTileFromSide(current_tile, LEFT) != -1)
                    {
                        TileFlipVertically(current_tile);
                    }
                }
                else
                {
                    // Any other tile in the row needs to make sure that it's LEFT neighbor
                    // is correct.
                    s16 left_tile_index = board[r*12 + (c-1)];
                    if (TileGetConnectingTileFromSide(current_tile, LEFT) != left_tile_index)
                    {
                        TileFlipVertically(current_tile);
                    }
                }

                board[r*12 + c] = current_tile_index;

            }
        }
    }
    PrintBoard(board, all_tiles);

    // ______________________
    // |                  # |
    // |#    ##    ##    ###|
    // | #  #  #  #  #  #   |
    // ----------------------
    const int sea_monster_H = 3;
    const int sea_monster_W = 20;
    s8[sea_monster_W*sea_monster_H] sea_monster;
    sea_monster = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,
                   1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,
                   0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0];

    s8[96*96] image;
    s8[96*96] scratch_image;
    ConstructImageFromBoard(board, all_tiles, image);

    int num_sea_monsters = 0;
    foreach (rot; 0 .. 4)
    {
        PrintImage(image);
        writeln("-----------------------------------------------------------------------------------------------------");
        writeln();

        for (int r=0; r<(96 - sea_monster_H); r++)
        {
            for (int c=0; c<(96 - sea_monster_W); c++)
            {
                if (ImageMatchSubImage(image, sea_monster, r, c))
                {
                    num_sea_monsters += 1;
                    writeln("2: Rotation ", rot, " found sea monster ", num_sea_monsters);
                }
            }
        }

        if (num_sea_monsters > 0)
            break;

        ImageRotateCW(image, scratch_image);
    }

    int original_number_of_black_pixels = 0;
    for (int r=0; r<96; r++)
    {
        for (int c=0; c<96; c++)
        {
            if (image[r*96 + c] != WHITE_PIXEL)
            {
                original_number_of_black_pixels += 1;
            }
        }
    }

    for (int r=0; r<(96 - sea_monster_H); r++)
    {
        for (int c=0; c<(96 - sea_monster_W); c++)
        {
            if (ImageMatchSubImage(image, sea_monster, r, c))
            {
                ImageMaskSubImage(image, sea_monster, r, c);
            }
        }
    }

    int final_number_of_black_pixels = 0;
    for (int r=0; r<96; r++)
    {
        for (int c=0; c<96; c++)
        {
            if (image[r*96 + c] != WHITE_PIXEL)
            {
                final_number_of_black_pixels += 1;
            }
        }
    }

    writeln("2: result = ", final_number_of_black_pixels, " (original was ", original_number_of_black_pixels, ")");
}
