//! zinc
library CombatFacts {
    public unit whichBoss = null;    
    
    public struct DBMArchTinker {
        static real gripRange = 1200.0;
        static real bombAOE = 200.0;
        static real selfDestructAOE = 250.0;
        static real laserBeamAOE = 105.0;
        static unit bombTarget = null;
        static unit laserTarget = null;
        static integer numberOfFactory = 0;
        static real laserX = 0.0;
        static real laserY = 0.0;
        static integer shieldStack = 0;
    }
    
    public struct DBMNagaSeaWitch {
        static unit stormTarget = null;
        static real forkedLightningAOE = 200.0;
        static real safeRange = 450.0;
        static boolean isStorm = false;
    }
	
	public struct DBMTideBaron {
		static real safeAngle = 30.0;
		static real alkalineWaterAOE = 200.0;
		static real safeAggroPercent = 0.75;
	}
	
	public struct DBMWarlock {
		static unit theBolt = null;
        static boolean isFireBomb = false;
	}
	
	public struct DBMAbyssArchon {
	
	}
	
	public struct DBMTheFelguards {
	
	}
    
    public struct DBMHexLord {
        static integer absorb = 0;
        static integer spell1 = 0;
        static integer spell2 = 0;
        static boolean canOverpower = false;
    }
	
	public struct DBMHighWarlord {
	
	}
}
//! endzinc
