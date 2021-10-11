module draw;
import std.stdio;
import std.format: format;

const BLOCKS_TABLE = " ▏▎▍▌▋▊▉█"d;
const RIGHT_HALF = "▐"d;

void drawpercent(string name, float totalMs, float percent) {
    // auto percentString = percent.format!"%.2f";
    // auto totalMsString = totalMs.format!"%.2f";
    writef!"%-20s %8.2f%% (%8.2fms) "(name, percent, totalMs);
    auto blocks = percent / 2.5;
    if(blocks <= 4) {
        writeln("│ (too small)");
        return;
    }
    if(percent > 600) {
        writeln("│ (too big)");
        return;
    }
    write(RIGHT_HALF);
    blocks -= 4;
    while(blocks >= 8) {
        write(BLOCKS_TABLE[8]);
        blocks -= 8;
    }
    if(blocks > 0) {
        writeln(BLOCKS_TABLE[cast(int)blocks]);
    } else {
        writeln;
    }
}