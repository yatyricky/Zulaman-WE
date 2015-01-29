//! zinc
library Integer {
//==============================================================================
//  string:     I2HEX(integer i) 
//  string:     ID2S(integer i) 
//  integer:    S2ID(string IDString) 
//==============================================================================
    
    private constant string STR_LIST = "................................ !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~.................................................................................................................................";
    
    public function I2HEX(integer i) -> string {
        string ret = "";
        integer dig;
        integer mod = 0x10000000;
        while (i > 0) {
            dig = i / mod;
            if (dig < 10) {
                ret += I2S(dig);
            } else {
                ret += SubString(STR_LIST, dig + 55, dig + 56);
            }
            i -= dig * mod;
            mod /= 0x10;
        }
        return ret;
    }
    
    public function ID2S(integer i) -> string {
        string ret = "";
        integer dig;
        integer mod = 0x1000000;
        while (i > 0) {
            dig = i / mod;
            ret += SubString(STR_LIST, dig, dig + 1);
            i -= dig * mod;
            mod /= 0x100;
        }
        return ret;
    }

    private function getInt(string s) -> integer {
        if (s == " ") {return 32;}
        if (s == "!") {return 33;}
        if (s == "\"") {return 34;}
        if (s == "#") {return 35;}
        if (s == "$") {return 36;}
        if (s == "%") {return 37;}
        if (s == "&") {return 38;}
        if (s == "'") {return 39;}
        if (s == "(") {return 40;}
        if (s == ")") {return 41;}
        if (s == "*") {return 42;}
        if (s == "+") {return 43;}
        if (s == ",") {return 44;}
        if (s == "-") {return 45;}
        if (s == ".") {return 46;}
        if (s == "/") {return 47;}
        if (s == "0") {return 48;}
        if (s == "1") {return 49;}
        if (s == "2") {return 50;}
        if (s == "3") {return 51;}
        if (s == "4") {return 52;}
        if (s == "5") {return 53;}
        if (s == "6") {return 54;}
        if (s == "7") {return 55;}
        if (s == "8") {return 56;}
        if (s == "9") {return 57;}
        if (s == ":") {return 58;}
        if (s == ";") {return 59;}
        if (s == "<") {return 60;}
        if (s == "=") {return 61;}
        if (s == ">") {return 62;}
        if (s == "?") {return 63;}
        if (s == "@") {return 64;}
        if (s == "A") {return 65;}
        if (s == "B") {return 66;}
        if (s == "C") {return 67;}
        if (s == "D") {return 68;}
        if (s == "E") {return 69;}
        if (s == "F") {return 70;}
        if (s == "G") {return 71;}
        if (s == "H") {return 72;}
        if (s == "I") {return 73;}
        if (s == "J") {return 74;}
        if (s == "K") {return 75;}
        if (s == "L") {return 76;}
        if (s == "M") {return 77;}
        if (s == "N") {return 78;}
        if (s == "O") {return 79;}
        if (s == "P") {return 80;}
        if (s == "Q") {return 81;}
        if (s == "R") {return 82;}
        if (s == "S") {return 83;}
        if (s == "T") {return 84;}
        if (s == "U") {return 85;}
        if (s == "V") {return 86;}
        if (s == "W") {return 87;}
        if (s == "X") {return 88;}
        if (s == "Y") {return 89;}
        if (s == "Z") {return 90;}
        if (s == "[") {return 91;}
        if (s == "\\") {return 92;}
        if (s == "]") {return 93;}
        if (s == "^") {return 94;}
        if (s == "_") {return 95;}
        if (s == "`") {return 96;}
        if (s == "a") {return 97;}
        if (s == "b") {return 98;}
        if (s == "c") {return 99;}
        if (s == "d") {return 100;}
        if (s == "e") {return 101;}
        if (s == "f") {return 102;}
        if (s == "g") {return 103;}
        if (s == "h") {return 104;}
        if (s == "i") {return 105;}
        if (s == "j") {return 106;}
        if (s == "k") {return 107;}
        if (s == "l") {return 108;}
        if (s == "m") {return 109;}
        if (s == "n") {return 110;}
        if (s == "o") {return 111;}
        if (s == "p") {return 112;}
        if (s == "q") {return 113;}
        if (s == "r") {return 114;}
        if (s == "s") {return 115;}
        if (s == "t") {return 116;}
        if (s == "u") {return 117;}
        if (s == "v") {return 118;}
        if (s == "w") {return 119;}
        if (s == "x") {return 120;}
        if (s == "y") {return 121;}
        if (s == "z") {return 122;}
        if (s == "{") {return 123;}
        if (s == "|") {return 124;}
        if (s == "}") {return 125;}
        if (s == "~") {return 126;}
        return 0;
    }
    
    public function S2ID(string ids) -> integer {
        string s;
        integer r;
        if (StringLength(ids) != 4) {
            debug BJDebugMsg("|cffff0000IDString to integer|r: invalid id string");
            return 0;
        }
        r = 0;
        s = SubString(ids, 0, 1);
        if (getInt(s) == 0) {
            debug BJDebugMsg("|cffff0000IDString to integer|r: invalid id string");
            return 0;
        }
        //BJDebugMsg("Digit 3 - " + I2S(getInt(s)));
        r += getInt(s) * 0x1000000;
        s = SubString(ids, 1, 2);
        if (getInt(s) == 0) {
            debug BJDebugMsg("|cffff0000IDString to integer|r: invalid id string");
            return 0;
        }
        //BJDebugMsg("Digit 2 - " + I2S(getInt(s)));
        r += getInt(s) * 0x10000;
        s = SubString(ids, 2, 3);
        if (getInt(s) == 0) {
            debug BJDebugMsg("|cffff0000IDString to integer|r: invalid id string");
            return 0;
        }
        //BJDebugMsg("Digit 1 - " + I2S(getInt(s)));
        r += getInt(s) * 0x100;
        s = SubString(ids, 3, 4);
        if (getInt(s) == 0) {
            debug BJDebugMsg("|cffff0000IDString to integer|r: invalid id string");
            return 0;
        }
        //BJDebugMsg("Digit 0 - " + I2S(getInt(s)));
        r += getInt(s);
        return r;
    }
}
//! endzinc
