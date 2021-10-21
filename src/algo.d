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
// used tail optimization from basic2 algo
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

	auto rem = b.length - a.length;
	while(r && rem) {
		r = (*--cb + (r >> 1)) & 3;
		*--cr = '0' + (r & 1);
		rem--;
	}
	if(rem) (cr - rem)[0..rem] = (cb - rem)[0..rem];

	return cast(string)(r >> 1 ? result : result[1..$]);
}

// @Serg_Gini
string stackoverflow(string a, string b) {
	import std.algorithm;

	string s = "";
	int c = 0;
	int i = cast(int)(a.length), j = cast(int)(b.length);
	
	auto result = new char[max(a.length, b.length) + 1];
	auto r = result.length - 1;

	i--; j--;
	while ((i >= 0) || (j >= 0) || (c == 1)) {
		c += i >= 0 ? a[i--] - '0' : 0;
		c += j >= 0 ? b[j--] - '0' : 0;
		result[r--] = c % 2 + '0';
		c /= 2;
	}
	return cast(string) result[r+1..$];
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

// @pham_nuwen
string simdConvert(string a, string b) {

	static immutable ubyte[16] reverse_a = [
		0xF, 0xE, 0xD, 0xC, 0xB, 0xA, 0x9, 0x8, 
		0x7, 0x6, 0x5, 0x4, 0x3, 0x2, 0x1, 0x0
	];

	static immutable ubyte[16] unpack_a = [
		0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 
		0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	];

	import std.algorithm;
	import inteli.tmmintrin;

	auto add = _mm_set1_epi8(0x80 - '1');
	auto reverse = _mm_lddqu_si128(cast(__m128i*) reverse_a.ptr);
	auto unpack = _mm_lddqu_si128(cast(__m128i*) unpack_a.ptr);
	auto mask = _mm_set1_epi64(cast(__m64)0x0102040810204080);
	auto allOne = _mm_set1_epi8('1');
	auto allZero = _mm_setzero_si128();

	int toInteger(const char* str) {
		auto data = _mm_lddqu_si128(cast(__m128i*) str); // load digits
		data = _mm_shuffle_epi8(data, reverse);          // reverse digits
		data = _mm_add_epi8(data, add);                  // set MSB
		return _mm_movemask_epi8(data);                  // pack bits
	}

	void toString(int val, char* str) {
		auto data = _mm_set1_epi16(cast(ushort) val); // load ushort
		data = _mm_shuffle_epi8(data, unpack);        // distribute bytes
		data = _mm_and_si128(data, mask);             // select bits
		data = _mm_cmpeq_epi8(data, allZero);         // convert to -1/0
		data = _mm_add_epi8(data, allOne);            // make digits
		_mm_storeu_si128(cast(__m128i*)str, data);    // store digits
	}

	if(a.length > b.length) swap(a, b);
	auto result = new char[b.length + 1];
	result[0] = '1';

	auto ca = &a[0] + a.length;
	auto cb = &b[0] + b.length;
	auto cr = &result[0] + result.length;

	int r = 0;
	foreach(i; 0..a.length/16) {
		ca -= 16; cb -=16; cr -=16;
		r += toInteger(ca) + toInteger(cb);
		toString(r, cr);
		r = r >> 16;
	}

	r = r << 1;

	foreach(i; 0..a.length % 16) {
		r = (*--ca + *--cb + (r >> 1)) & 3;
		*--cr = '0' + (r & 1);
	}

	auto rem = b.length - a.length;
	while(r && rem) {
		r = (*--cb + (r >> 1)) & 3;
		*--cr = '0' + (r & 1);
		rem--;
	}
	if(rem) (cr - rem)[0..rem] = (cb - rem)[0..rem];

	return cast(string)((r >> 1) ? result : result[1..$]);
}
