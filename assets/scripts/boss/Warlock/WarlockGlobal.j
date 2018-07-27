//! zinc
library WarlockGlobal requires NefUnion, ZAMCore, Table {
    constant integer SAMPLE_SIDES = 8;
    constant real SAMPLE_MOVE_DISTANCE = 50.0;

    unit runes[];
    integer index;
    real xoff[];
    real yoff[];
    real facing[]; // facing for fire runes

    real heroBodySize = 60.0;
    public real platformRadius = 950;

    public struct DanceMatConst {
        static real destX[];
        static real destY[];
        static integer current;
        static real p1x, p1y, p2x, p2y;
        static real currentCD;

        static method getCurrent() {
            integer other = thistype.current + 1;
            if (other > 4) {other = 0;}
            thistype.p1x = thistype.destX[thistype.current];
            thistype.p1y = thistype.destY[thistype.current];
            thistype.p2x = thistype.destX[other];
            thistype.p2y = thistype.destY[other];
        }

        static method nextSector() {
            thistype.current += 1;
            if (thistype.current > 4) {thistype.current = 0;}
            thistype.currentCD -= 0.15;
            if (thistype.currentCD < 1) {thistype.currentCD = 1;}
        }

        static method reset() {
            thistype.currentCD = 8.0;
            thistype.current = 0;
        }

        static method onInit() {
            thistype.destX[0] = 5947.087575; thistype.destY[0] = 1203.095928;
            thistype.destX[1] = 4608.000; thistype.destY[1] = 2176.000;
            thistype.destX[2] = 3268.912425; thistype.destY[2] = 1203.095928;
            thistype.destX[3] = 3780.398365; thistype.destY[3] = -371.0959281;
            thistype.destX[4] = 5435.601635; thistype.destY[4] = -371.0959281;
            thistype.reset();
        }
    }

    public struct FireShiftConsts {
        static real AOE = 200.0;
        static real selfDamageRatio = 0.2;
        static ListObject ps;

        static method onInit() {
            thistype.ps = ListObject.create();
        }
    }

    public struct FireBombGroup {
        static unit bombs[];
        static integer size = 0;

        static method add(unit u) {
            thistype.bombs[thistype.size] = u;
            thistype.size += 1;
        }

        static method clear() {
            thistype.size = 0;
        }
    }

    public struct FlameThrowAux {
        static real radius = 200.0;
        static effect theBolt = null;
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
            runes[i] = CreateUnit(p, UTID_FIRE_RUNE, WLK_SQR_CENTRE_X + xoff[i], WLK_SQR_CENTRE_Y + yoff[i], facing[i]);
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
        xoff[0] = 0;    yoff[0] = 960;
        xoff[1] = -960;    yoff[1] = 262.519173114854;
        xoff[2] = -593.312629199899;    yoff[2] = -866.028511286695;
        xoff[3] = 593.312629199899;    yoff[3] = -866.028511286695;
        xoff[4] = 960;    yoff[4] = 262.519173114854;
        xoff[5] = 113.312629199899;    yoff[5] = 611.259586557427;
        xoff[6] = -113.312629199899;    yoff[6] = 611.259586557427;
        xoff[7] = -593.312629199899;    yoff[7] = 262.519173114854;
        xoff[8] = -663.343685400051;    yoff[8] = 46.9857443566525;
        xoff[9] = -480;    yoff[9] = -517.288097844122;
        xoff[10] = -296.656314599949;    yoff[10] = -650.495082528494;
        xoff[11] = 296.656314599949;    yoff[11] = -650.495082528494;
        xoff[12] = 480;    yoff[12] = -517.288097844122;
        xoff[13] = 663.343685400051;    yoff[13] = 46.9857443566525;
        xoff[14] = 593.312629199899;    yoff[14] = 262.519173114854;
        xoff[15] = 226.625258399798;    yoff[15] = 262.519173114854;
        xoff[16] = 0;    yoff[16] = 262.519173114854;
        xoff[17] = -226.625258399798;    yoff[17] = 262.519173114854;
        xoff[18] = -296.65631459995;    yoff[18] = 46.9857443566525;
        xoff[19] = -366.687370800101;    yoff[19] = -168.547684401548;
        xoff[20] = -183.343685400051;    yoff[20] = -301.754669085921;
        xoff[21] = 0;    yoff[21] = -434.961653770293;
        xoff[22] = 183.343685400051;    yoff[22] = -301.754669085921;
        xoff[23] = 366.687370800101;    yoff[23] = -168.547684401548;
        xoff[24] = 296.65631459995;    yoff[24] = 46.9857443566525;
        xoff[25] = 0;    yoff[25] = -49.4037352687364;
    }

    function onInit() {
        InitRuneVariables();
        InitRunes();
    }

}
//! endzinc
