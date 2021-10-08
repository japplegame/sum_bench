import algo;

immutable functions = [
	F("basic", &basic),
	F("Dark Hole", &dark_hole),
	F("Dark Hole 2", &dark_hole_opti),
	F("unrolled chunks 2", &unrolledChunks!2),
	F("unrolled chunks 16", &unrolledChunks!16),
	F("unrolled chunks 64", &unrolledChunks!64),
];

enum maxStringLength  = 100;
enum iterationsNumber = 100_000;

import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.random;
import std.algorithm;
import std.exception;
import std.datetime.stopwatch;

struct F {
	string name;
	string function(string, string) fun;
}


class BenchError : Exception {
	string a, b, r;
	this(string msg, string a, string b, string r, string file = __FILE__, size_t line = __LINE__) {
		this.a = a;
		this.b = b;
		this.r = r;
		super(msg, file, line);
	}
}

auto bench(in F test) {
	rndGen.seed(12345);

	string genStr() {
		return "1" ~ iota(0, uniform(1, maxStringLength)).map!(x => "01"[uniform(0, 2)]).array();
	}

	auto toNum(string str) {
		import std.bigint;
		return BigInt().reduce!((n, d) => n * 2 + (d == '0' ? 0 : 1))(str);
	}


	Duration time;
	auto watch = StopWatch(AutoStart.no);
	foreach(n; 0..iterationsNumber) {
		auto a = genStr();
		auto b = genStr();
		string r;
		try {
			watch.start();
			r = test.fun(a, b);
			watch.stop();
			time += watch.peek();
			watch.reset();
		} catch(Throwable e) {
			throw new BenchError("Bad function: " ~ e.msg, a, b, r);
		}
		if(toNum(r) != toNum(a) + toNum(b)) {
			throw new BenchError("Wrong result", a, b, r);
		}
	}
	return time;
}

void main() {
	writefln("running benchmarks...");
	auto results = 
		functions.map!((f) {
			writef("%-20s", f.name);
			try {
				auto time = f.bench();
				writeln("ok");
				return time.total!"usecs";
			} catch(BenchError e) {
				writefln("failed");
				writefln("  %s", e.msg);
				writefln("    a = %s", e.a);
				writefln("    b = %s", e.b);
				writefln("    r = %s", e.r);
				return long.max;
			}
		}).array();
	auto indexes = new size_t[results.length];
	results.makeIndex(indexes);
	auto fastest = results[indexes[0]];

	writefln("┌──────────────────────┬───────────┬─────────┐");
	writefln("│         Name         │    Abs    │   Rel   │");
	foreach(i; indexes) {
		writeln("├──────────────────────┼───────────┼─────────┤");
		writef("│ %-21s│", functions[i].name);
		if(results[i] < long.max) {
			writefln!"%8.2fms │ %6s%% │"(results[i] / 1000.0, results[i] * 100 / fastest);
		} else {
			writeln("     -     │    -    │");
		}
	}
	writefln("└──────────────────────┴───────────┴─────────┘");
}
