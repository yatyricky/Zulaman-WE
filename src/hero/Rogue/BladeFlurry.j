//! zinc
library BladeFlurry requires DamageSystem, SpellEvent, RogueGlobal {
#define ART "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl"
#define ART_OPEN "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl"
#define ART_CLEAVE "Abilities\\Spells\\Other\\Cleave\\CleaveDamageTarget.mdl"
#define BUFF_ID 'A048'

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.i1 = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDBLADEFLURRY);
        buf.bd.interval = 9.0 + buf.bd.i1;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 40;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atCoord(ART_OPEN, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0.5);
    }
    
    struct delayedDosth1 {
        private timer tm;
        private unit sor, tar;
        private real amt;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            while (i < MobList.n) {  
                if (GetDistance.units2d(MobList.units[i], this.tar) < 200 && !IsUnit(this.tar, MobList.units[i])) {
                    DamageTarget(this.sor, MobList.units[i], this.amt, SpellData[SIDBLADEFLURRY].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
                    AddTimedEffect.atUnit(ART_CLEAVE, MobList.units[i], "origin", 0.2);                    
                }
                i += 1;
            }
            
            ReleaseTimer(this.tm);
            this.tm = null;
            this.sor = null;
            this.tar = null;
            this.deallocate();
        }
    
        static method start(unit sor, unit tar, real amt) {
            thistype this = thistype.allocate();
            this.sor = sor;
            this.tar = tar;
            this.amt = amt;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }
    
    function damaged() {
        Buff buf = BuffSlot[DamageResult.source].getBuffByBid(BUFF_ID);
        if (buf != 0 && DamageResult.isHit && DamageResult.abilityName != SpellData[SIDBLADEFLURRY].name) {
            delayedDosth1.start(DamageResult.source, DamageResult.target, (0.55 + 0.15 * buf.bd.i1) * DamageResult.amount);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDBLADEFLURRY, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterDamagedEvent(damaged);
    }
#undef BUFF_ID
#undef ART_CLEAVE
#undef ART_OPEN
#undef ART
}
//! endzinc
