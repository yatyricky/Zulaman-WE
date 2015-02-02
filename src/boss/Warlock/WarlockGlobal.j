//! zinc
library WarlockGlobal requires NefUnion, ZAMCore {
    unit runes[];
    integer index;
    real xoff[];
    real yoff[];
    real facing[];
	real xfb[];
	real yfb[];
	integer nfb = 0;
	real fbAOE = 150.0;
	integer hexN;
	public real platformRadius = 950;
	
	function InitFireBombPlot() {
		integer i, j;
		real y, x, d;
		hexN = R2I(platformRadius / 1.732050807568877 / fbAOE) * 2;
		// http://stackoverflow.com/questions/14280831/algorithm-to-generate-2d-magic-hexagon-lattice
		d = fbAOE;// d is the distance between 2 points as indicated in your schema
		i = 0;
		while (i < hexN) {
			y = (1.732050807568877 * i * d) / 2.0;
			j = 0;
			while (j < (2 * hexN - 1 - i)) {
				x = (-(2*hexN-i-2)*d)/2.0 + j*d;
				//plot the point with coordinate (x,y) here
				xfb[nfb] = x + WLKSQRCENTREX;
				yfb[nfb] = y + WLKSQRCENTREY;
				nfb += 1;
				if (y != 0) {
					// plot the point with coordinate (x,-y) here
					xfb[nfb] = x + WLKSQRCENTREX;
					yfb[nfb] = WLKSQRCENTREY - y;
					nfb += 1;
				}
				j += 1;
			}
			i += 1;
		}
		// test
		i = 0;
		while (i < nfb) {
			CreateUnit(Player(10), 'ewsp', xfb[i], yfb[i], 0);
			i += 1;
		}
	}
    
    public function GetFireRune() -> unit {
        if (index < 26) {
            return runes[index];
        } else {
            return null;
        }
    }
    
    public function NextFireRune() {
        index += 1;
    }
    
    public function ResetFireRunes() {
        player p = Player(MOB_PID);
        integer i = 0;
        while (i < 26) {
            if (runes[i] != null) {
                if (!IsUnitDead(runes[i])) {
                    KillUnit(runes[i]);
                }
            }
            runes[i] = CreateUnit(p, UTIDFIRERUNE, WLKSQRCENTREX + xoff[i], WLKSQRCENTREY + yoff[i], facing[i]);
            i += 1;
        }
        index = 0;
        p = null;
    }

    function InitRunes() {
        integer i = 0;
        while (i < 26) {
            runes[i] = null;
            facing[i] = GetAngleDeg(0.0, 0.0, xoff[i], yoff[i]);
            i += 1;
        }
        ResetFireRunes();
    }
    
    function InitRuneVariables() {
xoff[0] = 0;	yoff[0] = 960;
xoff[1] = -960;	yoff[1] = 262.519173114854;
xoff[2] = -593.312629199899;	yoff[2] = -866.028511286695;
xoff[3] = 593.312629199899;	yoff[3] = -866.028511286695;
xoff[4] = 960;	yoff[4] = 262.519173114854;
xoff[5] = 113.312629199899;	yoff[5] = 611.259586557427;
xoff[6] = -113.312629199899;	yoff[6] = 611.259586557427;
xoff[7] = -593.312629199899;	yoff[7] = 262.519173114854;
xoff[8] = -663.343685400051;	yoff[8] = 46.9857443566525;
xoff[9] = -480;	yoff[9] = -517.288097844122;
xoff[10] = -296.656314599949;	yoff[10] = -650.495082528494;
xoff[11] = 296.656314599949;	yoff[11] = -650.495082528494;
xoff[12] = 480;	yoff[12] = -517.288097844122;
xoff[13] = 663.343685400051;	yoff[13] = 46.9857443566525;
xoff[14] = 593.312629199899;	yoff[14] = 262.519173114854;
xoff[15] = 226.625258399798;	yoff[15] = 262.519173114854;
xoff[16] = 0;	yoff[16] = 262.519173114854;
xoff[17] = -226.625258399798;	yoff[17] = 262.519173114854;
xoff[18] = -296.65631459995;	yoff[18] = 46.9857443566525;
xoff[19] = -366.687370800101;	yoff[19] = -168.547684401548;
xoff[20] = -183.343685400051;	yoff[20] = -301.754669085921;
xoff[21] = 0;	yoff[21] = -434.961653770293;
xoff[22] = 183.343685400051;	yoff[22] = -301.754669085921;
xoff[23] = 366.687370800101;	yoff[23] = -168.547684401548;
xoff[24] = 296.65631459995;	yoff[24] = 46.9857443566525;
xoff[25] = 0;	yoff[25] = -49.4037352687364;

    }

    function onInit() {
        InitRuneVariables();
        InitRunes();
		InitFireBombPlot();
    }
}
//! endzinc
