module algo;

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

// @darkhole1
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

// @darkhole1
string dark_hole_opti(string a, string b) {
	if(a.length > b.length) {
		string t = a;
		a = b;
		b = t;
	}
	char[] res = new char[b.length+1];
	int last = false;
	int i = cast(int)a.length - 1,
		j = cast(int)b.length - 1, 
		k = cast(int)res.length - 1;
	for(;i >= 0; i--, j--, k--) {
		auto c1 = a[i] ^ '0';
		auto c2 = b[j] ^ '0';
		auto sum = c1 + c2 + last;
		last = sum >> 1;
		res[k] = sum & 1 ? '1' : '0';
	}
	for(; last && j >= 0; j--, k--) {
		if(b[j] == '1') {
			res[k] = '0';
		} else {
			res[k] = '1';
			last = false;
		}
	}
	if(j >= 0) {
		res[k-j..k+1] = b[0..j+1];
	}
	if(last) {
		res[0] = '1';
		return cast(immutable)res;
	}
	return cast(immutable)res[1..$];
}

// @pham_nuwen
string unrolledChunks(size_t chunkSize)(string a, string b) {
	import std.algorithm;

	if(a.length > b.length) swap(a, b);
	auto result = new char[b.length + 1];
	result[0] = '1';

	auto ca = &a[0] + a.length;
	auto cb = &b[0] + b.length;
	auto cr = &result[0] + result.length;
	int r = 0;

	foreach(i; 0..a.length / chunkSize) {
		static foreach(j; 0..chunkSize) {
			r = (*--ca + *--cb + (r >> 1)) & 3;
			*--cr = '0' + (r & 1);
		}
	}

	foreach(i; 0..a.length % chunkSize) {
		r = (*--ca + *--cb + (r >> 1)) & 3;
		*--cr = '0' + (r & 1);
	}

	foreach(i; 0..b.length - a.length) {
		r = (*--cb + (r >> 1)) & 3;
		*--cr = '0' + (r & 1);
	}
	return cast(string)(r >> 1 ? result : result[1..$]);
}

// @Serg_Gini
string stackoverflow(string a, string b) {
	import std.conv;
	string s = "";
	int c = 0;
	int i = cast(int)(a.length), j = cast(int)(b.length);
	i--; j--;
	while ((i >= 0) || (j >= 0) || (c == 1)) {
		c += i >= 0 ? a[i--] - '0' : 0;
		c += j >= 0 ? b[j--] - '0' : 0;
		s = to!char(c % 2 + '0') ~ s;
		c /= 2;
	}
	return s;
}

// @yaisis
string basic2(string a, string b) {
	if(a.length > b.length) { auto c = b; b = a; a = c; }
	char[] res = new char[b.length+1];
	auto i = a.length;
	auto c = b[$-i..$];
	auto rs = res[$-i..$];
	int cf;
	while(i) {
		i--;
		auto r = a[i]+c[i]-2*'0'+cf;
		cf = r>>1;
		rs[i] = (r & 1) + '0';
	}
	rs = res[1..$];
	i = b.length-a.length;
	while(cf && i) {
		i--;
		auto r = b[i]-'0'+cf;
		cf = r>>1;
		rs[i] = (r & 1) + '0';
	}
	rs[0..i] = b[0..i];
	if(cf) res[0]='1';
	else return cast(immutable)rs;
  	
  	return cast(immutable)res;
}
