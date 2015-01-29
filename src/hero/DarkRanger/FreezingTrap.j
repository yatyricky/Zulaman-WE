//! zinc
library FreezingTrap requires SpellEvent, StunUtils, AggroSystem {
#define ART "Doodads\\Cinematic\\FrostTrapUp\\FrostTrapUp.mdl"
#define ART1 "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl"
#define PATH "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes4.mdl"
#define PATH1 "Abilities\\Spells\\NightElf\\TrueshotAura\\TrueshotAura.mdl"
#define SFX "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl"
#define SFX1 "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"

    hashtable terrainRecord = InitHashtable();
    hashtable readyModify = InitHashtable();
    
    function returnAOE(integer lvl) -> real {
        return 150.0 + 150 * lvl;
    }
    
    function returnDelay(integer lvl) -> real {
        return 1.2 - 0.3 * lvl;
    }
    
    function returnSpeedReduc(integer lvl) -> real {
        return 0.25 + 0.15 * lvl;
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }
    
    function RecordTerrain(integer x, integer y) {
        if (!HaveSavedInteger(readyModify, x, y)) {
            SaveInteger(readyModify, x, y, 1);
        } else {
            SaveInteger(readyModify, x, y, LoadInteger(readyModify, x, y) + 1);
        }
        if (!HaveSavedInteger(terrainRecord, x, y)) {
            SaveInteger(terrainRecord, x, y, GetTerrainType(x * 128.0, y * 128.0));
        }
    }
    
    function RecoverTerrain(integer x, integer y) {
        integer i = LoadInteger(readyModify, x, y);
        i -= 1;
        if (i < 1) {
            i = 0;
            SetTerrainType(x * 128.0, y * 128.0, LoadInteger(terrainRecord, x, y), -1, 1, 0);
        }
        SaveInteger(readyModify, x, y, i);
    }
    
    struct TerrainChange {
        timer tm;
        integer x, y;
        integer prev;
        integer lvl;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            RecoverTerrain(this.x, this.y);
            RecoverTerrain(this.x, this.y + 2);
            RecoverTerrain(this.x, this.y + 1);
            RecoverTerrain(this.x, this.y - 1);
            RecoverTerrain(this.x, this.y - 2);
            RecoverTerrain(this.x + 2, this.y);
            RecoverTerrain(this.x + 1, this.y);
            RecoverTerrain(this.x - 1, this.y);
            RecoverTerrain(this.x - 2, this.y);
            RecoverTerrain(this.x - 1, this.y - 1);
            RecoverTerrain(this.x - 1, this.y + 1);
            RecoverTerrain(this.x + 1, this.y - 1);
            RecoverTerrain(this.x + 1, this.y + 1);
            // lvl 2
            if (this.lvl > 1) {
                RecoverTerrain(this.x - 2, this.y + 1);
                RecoverTerrain(this.x - 1, this.y + 2);
                RecoverTerrain(this.x + 1, this.y + 2);
                RecoverTerrain(this.x + 2, this.y + 1);
                RecoverTerrain(this.x + 2, this.y - 1);
                RecoverTerrain(this.x + 1, this.y - 2);
                RecoverTerrain(this.x - 1, this.y - 2);
                RecoverTerrain(this.x - 2, this.y - 1);
                RecoverTerrain(this.x - 3, this.y    );
                RecoverTerrain(this.x,     this.y + 3);
                RecoverTerrain(this.x + 3, this.y    );
                RecoverTerrain(this.x    , this.y - 3);
                RecoverTerrain(this.x - 2, this.y + 2);
                RecoverTerrain(this.x + 2, this.y + 2);
                RecoverTerrain(this.x + 2, this.y - 2);
                RecoverTerrain(this.x - 2, this.y - 2);
            }
            // lvl 3
            if (this.lvl > 2) {
                RecoverTerrain(this.x - 3, this.y + 1);
                RecoverTerrain(this.x - 1, this.y + 3);
                RecoverTerrain(this.x + 1, this.y + 3);
                RecoverTerrain(this.x + 3, this.y + 1);
                RecoverTerrain(this.x + 3, this.y - 1);
                RecoverTerrain(this.x + 1, this.y - 3);
                RecoverTerrain(this.x - 1, this.y - 3);
                RecoverTerrain(this.x - 3, this.y - 1);                
                RecoverTerrain(this.x - 4, this.y    );
                RecoverTerrain(this.x + 4, this.y    );
                RecoverTerrain(this.x    , this.y + 4);
                RecoverTerrain(this.x    , this.y - 4);
                RecoverTerrain(this.x - 3, this.y + 2);
                RecoverTerrain(this.x - 2, this.y + 3);
                RecoverTerrain(this.x + 2, this.y + 3);
                RecoverTerrain(this.x + 3, this.y + 2);
                RecoverTerrain(this.x + 3, this.y - 2);
                RecoverTerrain(this.x + 2, this.y - 3);
                RecoverTerrain(this.x - 2, this.y - 3);
                RecoverTerrain(this.x - 3, this.y - 2);
            }
            ReleaseTimer(this.tm);
            this.tm = null;
            this.deallocate();
        }
        
        static method start(real x, real y, integer lvl) {
            thistype this = thistype.allocate();
            this.lvl = lvl;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.x = R2I(x / 128.0);
            this.y = R2I(y / 128.0);
            // lvl 1
            RecordTerrain(this.x, this.y);
            RecordTerrain(this.x, this.y + 2);
            RecordTerrain(this.x, this.y + 1);
            RecordTerrain(this.x, this.y - 1);
            RecordTerrain(this.x, this.y - 2);
            RecordTerrain(this.x + 2, this.y);
            RecordTerrain(this.x + 1, this.y);
            RecordTerrain(this.x - 1, this.y);
            RecordTerrain(this.x - 2, this.y);
            RecordTerrain(this.x - 1, this.y - 1);
            RecordTerrain(this.x - 1, this.y + 1);
            RecordTerrain(this.x + 1, this.y - 1);
            RecordTerrain(this.x + 1, this.y + 1);
            // lvl 2
            if (lvl > 1) {
            //print("?????????");
                RecordTerrain(this.x - 2, this.y + 1);
                RecordTerrain(this.x - 1, this.y + 2);
                RecordTerrain(this.x + 1, this.y + 2);
                RecordTerrain(this.x + 2, this.y + 1);
                RecordTerrain(this.x + 2, this.y - 1);
                RecordTerrain(this.x + 1, this.y - 2);
                RecordTerrain(this.x - 1, this.y - 2);
                RecordTerrain(this.x - 2, this.y - 1);
                RecordTerrain(this.x - 3, this.y    );
                RecordTerrain(this.x,     this.y + 3);
                RecordTerrain(this.x + 3, this.y    );
                RecordTerrain(this.x    , this.y - 3);
                RecordTerrain(this.x - 2, this.y + 2);
                RecordTerrain(this.x + 2, this.y + 2);
                RecordTerrain(this.x + 2, this.y - 2);
                RecordTerrain(this.x - 2, this.y - 2);
            }
            // lvl 3
            if (lvl > 2) {
                RecordTerrain(this.x - 3, this.y + 1);
                RecordTerrain(this.x - 1, this.y + 3);
                RecordTerrain(this.x + 1, this.y + 3);
                RecordTerrain(this.x + 3, this.y + 1);
                RecordTerrain(this.x + 3, this.y - 1);
                RecordTerrain(this.x + 1, this.y - 3);
                RecordTerrain(this.x - 1, this.y - 3);
                RecordTerrain(this.x - 3, this.y - 1);                
                RecordTerrain(this.x - 4, this.y    );
                RecordTerrain(this.x + 4, this.y    );
                RecordTerrain(this.x    , this.y + 4);
                RecordTerrain(this.x    , this.y - 4);
                RecordTerrain(this.x - 3, this.y + 2);
                RecordTerrain(this.x - 2, this.y + 3);
                RecordTerrain(this.x + 2, this.y + 3);
                RecordTerrain(this.x + 3, this.y + 2);
                RecordTerrain(this.x + 3, this.y - 2);
                RecordTerrain(this.x + 2, this.y - 3);
                RecordTerrain(this.x - 2, this.y - 3);
                RecordTerrain(this.x - 3, this.y - 2);
            }
            SetTerrainType(this.x * 128, this.y * 128, 'Wsnw', -1, 2 + lvl, 0);
            TimerStart(this.tm, 5.0, false, function thistype.run);
        }
    }
    
    struct FreezngTrap {
        private timer tm;
        private unit u;
        private real x, y;
        private effect trap;
        private integer count;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.trap = null;
            this.deallocate();
        }
        
        private method frostSlowAreaOfEffect() {
            Buff buf;
            integer i = 0;
            integer lvl = GetUnitAbilityLevel(this.u, SIDFREEZINGTRAP);
            while (i < MobList.n) {
                if (GetDistance.unitCoord2d(MobList.units[i], this.x, this.y) <= returnAOE(lvl)) {
                    buf = Buff.cast(this.u, MobList.units[i], BID_FREEZING_TRAP);
                    buf.bd.tick = -1;
                    buf.bd.interval = 1.1;
                    UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
                    buf.bd.i0 = Rounding(GetUnitMoveSpeed(buf.bd.target) * returnSpeedReduc(lvl));
                    if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(SFX1, buf, "origin");}
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
                i += 1;
            }
        }
        
        private static method frostThem() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.frostSlowAreaOfEffect();
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
        }
        
        private static method frostEffect() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.frostSlowAreaOfEffect();            
            TerrainChange.start(this.x, this.y, GetUnitAbilityLevel(this.u, SIDFREEZINGTRAP));
            this.count = 5;
            TimerStart(this.tm, 1.0, true, function thistype.frostThem);
        }
        
        private static method watchout() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            unit near = null;
            real dis = 100.0;
            real tmp;
            while (i < MobList.n) {
                tmp = GetDistance.unitCoord2d(MobList.units[i], this.x, this.y);
                if (tmp <= dis) {
                    near = MobList.units[i];
                    dis = tmp;
                }
                i += 1;
            }
            if (near != null) {
                AddTimedEffect.atCoord(ART, this.x, this.y, 2.0);
                AddTimedEffect.atCoord(ART1, this.x, this.y, 0.1);
                StunUnit(this.u, near, 5.0);                
                AddTimedEffect.atUnit(SFX, near, "origin", 5.0);
                DestroyEffect(this.trap);
                TimerStart(this.tm, 5.0, false, function thistype.frostEffect);
            } else {
                this.count -= 1;
                if (this.count < 1) {
                    DestroyEffect(this.trap);
                    this.destroy();
                }
            }
        }
        
        private static method trapReady() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.trap = AddSpecialEffect(PATH, this.x, this.y);
            this.count = 100;
            TimerStart(this.tm, 0.3, true, function thistype.watchout);
        }
    
        static method start(unit u, real x, real y, real dur) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = u;
            this.x = x;
            this.y = y;
            AddTimedEffect.atCoord(PATH1, x, y, 0.1);
            TimerStart(this.tm, dur, false, function thistype.trapReady);
        }
    }

    function onCast() {
        FreezngTrap.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY, returnDelay(GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDFREEZINGTRAP)));
        //TerrainChange.start(SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDFREEZINGTRAP, onCast);
        BuffType.register(BID_FREEZING_TRAP, BUFF_PHYX, BUFF_NEG);
    }
#undef SFX1
#undef SFX
#undef PATH1
#undef PATH
#undef ART1
#undef ART
}
//! endzinc
