//! zinc
library StringUtils {
    public function StringFind(string str, string find, integer i) -> integer {
        integer ls = StringLength(str);
        integer lf = StringLength(find);
        integer diff = ls - lf;

        while (i <= diff) {
            if (SubString(str, i, i + lf) == find) {
                return i;
            }
            i += 1;
        }

        return -1;
    }

    public function StringReplace(string str, string pattern, string replace) -> string {
        integer index = StringFind(str, pattern, 0);
        integer ls, lp;
        if (index == -1) {
            return str;
        }

        ls = StringLength(str);
        lp = StringLength(pattern);
        return SubString(str, 0, index) + replace + SubString(str, index + lp, ls);
    }

    public function StringFormat1(string template, string s1) -> string {
        return StringReplace(template, "{0}", s1);
    }

    public function StringFormat2(string template, string s1, string s2) -> string {
        string ret = StringReplace(template, "{0}", s1);
        ret = StringReplace(ret, "{1}", s2);
        return ret;
    }
}
//! endzinc
