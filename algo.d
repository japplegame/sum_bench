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