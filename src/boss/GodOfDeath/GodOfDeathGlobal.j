//! zinc
library GodOfDeathGlobal {
    //! runtextmacro WriteArrayList("MindBlastSpots", "Point", "0")

    public struct GodOfDeathGlobalConst {
    	static real mindBlastAOE = 300.0;
    	static real psychicLinkRange = 300.0;
    }

    public struct GodOfDeathPlatform {
    	static unit theFilthyTentacle = null;
    	static unit theViciousTentacle = null;
    	static unit theFoulTentacle = null;
    	static real filthyX = 123;
    	static real filthyY = 456;
    	static real viciousX = 123;
    	static real viciousY = 456;
    	static real foulX = 123;
    	static real foulY = 456;

    	static method reset() {
    		thistype.theFilthyTentacle = CreateUnit(Player(MOB_PID), UTID, thistype.filthyX, thistype.filthyY, 0);
    		thistype.theViciousTentacle = CreateUnit(Player(MOB_PID), UTID, thistype.viciousX, thistype.viciousY, 0);
    		thistype.theFoulTentacle = CreateUnit(Player(MOB_PID), UTID, thistype.foulX, thistype.foulY, 0);
    	}

    	static method getRandomPoint() -> Point {
    		integer i = 0;
    		Point ret;
    		if (thistype.theFilthyTentacle == null && thistype.theViciousTentacle == null && thistype.theFoulTentacle == null) {
    			return 0;
    		} else {
    			ret = Point.new(0, 0);
	    		if (thistype.theFilthyTentacle != null) {
	    			i += 1;
	    			if (GetRandomInt(1, i) == 1) {
	    				ret.x = thistype.filthyX;
	    				ret.y = thistype.filthyY;
	    			}
	    		}
	    		if (thistype.theViciousTentacle != null) {
	    			i += 1;
	    			if (GetRandomInt(1, i) == 1) {
	    				ret.x = thistype.viciousX;
	    				ret.y = thistype.viciousY;
	    			}
	    		}
	    		if (thistype.theFoulTentacle != null) {
	    			i += 1;
	    			if (GetRandomInt(1, i) == 1) {
	    				ret.x = thistype.foulX;
	    				ret.y = thistype.foulY;
	    			}
	    		}
	    		return ret;
	    	}
    	}
    }

    function platformTentacleDeath(unit u) {
    	integer utid = GetUnitTypeId(u);
    	if (utid == UTID) {
    		GodOfDeathPlatform.theFilthyTentacle = null;
    	}
    	if (utid == UTID) {
    		GodOfDeathPlatform.theViciousTentacle = null;
    	}
    	if (utid == UTID) {
    		GodOfDeathPlatform.theFoulTentacle = null;
    	}
    }

    function onInit() {
        RegisterUnitDeath(platformTentacleDeath);
    }
}
//! endzinc
