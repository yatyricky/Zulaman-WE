//! zinc
library SunField requires SpellEvent, TimerUtils, AggroSystem {
constant string  ART_CASTER  = "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl";
constant string  ART_EFFECT  = "Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl";
//constant integer BUFF_ID = 'A04F';

    function returnDamage(integer lvl) -> real {
        return 50.0 * lvl;
    }
    
    //function returnDamageGoesMana(integer lvl) -> real {
    //    return 0.02 + 0.01 * lvl;
    //}
    
    function returnDuration(integer lvl) -> integer {
        return 8;
    }

    //function onEffect(Buff buf) {
    //    UnitProp[buf.bd.target].damageGoesMana += buf.bd.r0;
    //}

    //function onRemove(Buff buf) {
    //    UnitProp[buf.bd.target].damageGoesMana -= buf.bd.r0;
    //}

    struct SunField {
        real dmg;
        integer count;
        unit caster;
        real aoe;
        timer tm;
        //real x, y;
        
        method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }
        
        method damageNearBy() {
            unit tu;
            GroupEnumUnitsInArea(ENUM_GROUP, GetUnitX(this.caster), GetUnitY(this.caster), this.aoe, BOOLEXPR_TRUE);
            tu = FirstOfGroup(ENUM_GROUP);
            while (tu != null) {
                if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(this.caster))) {
                    DamageTarget(this.caster, tu, this.dmg, SpellData[SID_SUN_FIRE_STORM].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    AggroTarget(this.caster, tu, this.dmg * 7.0);
                }
                GroupRemoveUnit(ENUM_GROUP, tu);
                tu = FirstOfGroup(ENUM_GROUP);
            }
            tu = null;
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (!IsUnitDead(this.caster)) {
                if (IsInCombat()) {
                    this.damageNearBy();
                }
            } else {
                this.count = 0;
            }
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
        }
    
        static method new(unit u) {
            thistype this = thistype.allocate();
            integer lvl = GetUnitAbilityLevel(u, SID_SUN_FIRE_STORM);
            real hst = 1.0 + UnitProp[u].AttackSpeed() / 100.0 + UnitProp[u].SpellHaste();
            this.caster = u;
            this.aoe = 250.0;
            this.count = Rounding(returnDuration(lvl) * hst);
            this.dmg = returnDamage(lvl) + UnitProp[u].SpellPower() * 0.33;
            //this.x = GetUnitX(u);
            //this.y = GetUnitY(u);
            this.damageNearBy();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0 / hst, true, function thistype.run);
            AddTimedEffect.atCoord(ART_CASTER, GetUnitX(this.caster), GetUnitY(this.caster), 0.0);
            AddTimedEffect.atUnit(ART_EFFECT, this.caster, "origin", returnDuration(lvl));
        }
    }

    function onCast() {
        //Buff buf;
        //integer lvl;
        SunField.new(SpellEvent.CastingUnit);
        
        //lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SUN_FIRE_STORM);
        //buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        //buf.bd.tick = -1;
        //buf.bd.interval = returnDuration(lvl);
        //UnitProp[buf.bd.target].damageGoesMana -= buf.bd.r0;
        //buf.bd.r0 = returnDamageGoesMana(lvl);
        //buf.bd.boe = onEffect;
        //buf.bd.bor = onRemove;
        //buf.run();    
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUN_FIRE_STORM, onCast);
        //BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }
//


}
//! endzinc
