import algo;
import draw;

immutable functions = [
	F("Dark Hole", &dark_hole),
	F("Dark Hole 2", &dark_hole_opti),
	F("unrolled chunks 2", &unrolledChunks!2),
	F("unrolled chunks 16", &unrolledChunks!16),
	F("unrolled chunks 64", &unrolledChunks!64),
	F("stackoverflow", &stackoverflow),
	F("basic2", &basic2),
	F("SIMD convert", &simdConvert),
	F("basic", &basic)
];

immutable benchSets = [
	Set(100, 100_000), // max string length = 100, 100к iterations
	Set(1000, 10_000),
	Set(10_000, 1000),
];

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

struct Set {
	int maxLength;
	int iterations;
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

auto bench(in F test, int maxLength, int iterations) {
	rndGen.seed(12345);

	string genStr() {
		return "1" ~ iota(0, uniform(1, maxLength)).map!(x => "01"[uniform(0, 2)]).array();
	}

	auto toNum(string str) {
		import std.bigint;
		return BigInt().reduce!((n, d) => n * 2 + (d == '0' ? 0 : 1))(str);
	}


	Duration time;
	auto watch = StopWatch(AutoStart.no);
	foreach(n; 0..iterations) {
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
		if(checksOn && toNum(r) != toNum(a) + toNum(b)) {
			throw new BenchError("Wrong result", a, b, r);
		}
	}
	return time;
}

bool checksOn = false;

void main(string[] args) {
	writefln("running benchmarks...");
	if(args.length > 1 && args[1] == "--checks") {
		writefln("checks on");
		checksOn = true;
	} else {
		writefln("checks off");
	}

	foreach(set; benchSets) {
		auto results = 
			functions.map!((f) {
				try {
					auto time = f.bench(set.maxLength, set.iterations);
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
		writefln("══════════════════════════════════════════════");
		writefln("max string length: %s", set.maxLength);
		writefln("iterations:        %s", set.iterations);
		foreach(i; indexes) {
			drawpercent(functions[i].name, results[i] / 1000.0, results[i] * 100 / fastest);
		}
	}
}
