immutable functions = [
	F("Basic", &basic),
	F("Dark Hole", &dark_hole)
];

string basic(string a, string b) {
	import std.string;
	
	if(a.length > b.length) b = b.rightJustify(a.length, '0');
	else a = a.rightJustify(b.length, '0');

	string result;
	int cf = 0;
	foreach_reverse(i; 0..a.length) {
		int r = a[i] + b[i] - 2 * '0' + cf;
		cf = r >> 1;
		result = (r & 1 ? '1' : '0') ~ result;
	}
	return cf ? "1" ~ result : result;
}

string dark_hole(string a, string b) {
	if(a.length > b.length) {
		string t = a;
		a = b;
		b = t;
	}
	char[] res = new char[b.length+1];
	bool last = false;
	bool f = false;
	size_t i = a.length - 1, j = b.length - 1, k = res.length - 1;
	for(;; i--, j--, k--) {
		auto c1 = a[i];
		auto c2 = b[j];
		if((c1 & c2) == '1') {
			res[k] = '0'+last;
			last = true;
		} else if(last && (c1|c2) == '1') {
			res[k] = '0';
		} else {
			res[k] = cast(char)((c1|c2)+last);
			last = false;
		}
		if(i == 0) {
			if(j != 0) j--;
			else f = true;
			k--;
			break;
		}
	}
	for(; last; j--, k--) {
		if(b[j] == '1') {
			res[k] = '0';
		} else {
			res[k] = '1';
			last = false;
		}
		if(j == 0) {
			f = true;
			break;
		}
	}
	if(!f) {
		for(;; j--, k--) {
			res[k] = b[j];
			if(j == 0) break;
		}
	}
	if(last) {
		res[0] = '1';
		return cast(immutable)res;
	}
	return cast(immutable)res[1..$];
}


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
		return "1" ~ iota(0, uniform(1, 100)).map!(x => "01"[uniform(0, 2)]).array();
	}

	auto toNum(string str) {
		import std.bigint;
		return BigInt().reduce!((n, d) => n * 2 + (d == '0' ? 0 : 1))(str);
	}


	Duration time;
	auto watch = StopWatch(AutoStart.no);
	foreach(n; 0..100_000) {
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
			stdout.flush();
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
			writefln("%8.2fms │ %6s%% │", results[i] / 1000.0, results[i] * 100 / fastest);
		} else {
			writefln("     -     │    -    │");
		}
	}
	writefln("└──────────────────────┴───────────┴─────────┘");
}
