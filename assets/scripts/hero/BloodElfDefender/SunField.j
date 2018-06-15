//! zinc
library SunField requires SpellEvent, TimerUtils, AggroSystem {

    function returnDamage(integer lvl) -> real {
        return 50.0 * lvl;
    }
    
    function returnDuration(integer lvl) -> integer {
        return 8;
    }

    struct SunField {
        real dmg;
        integer count;
        unit caster;
        real aoe;
        timer tm;
        
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
                    DamageTarget(this.caster, tu, this.dmg, SpellData.inst(SID_SUN_FIRE_STORM, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
                    AggroTarget(this.caster, tu, this.dmg * 7.0, SCOPE_PREFIX);
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
            real hst = 1.0 + UnitProp.inst(u, SCOPE_PREFIX).AttackSpeed() / 100.0 + UnitProp.inst(u, SCOPE_PREFIX).SpellHaste();
            this.caster = u;
            this.aoe = 250.0;
            this.count = Rounding(returnDuration(lvl) * hst);
            this.dmg = returnDamage(lvl) + UnitProp.inst(u, SCOPE_PREFIX).SpellPower() * 0.33;
            this.damageNearBy();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0 / hst, true, function thistype.run);
            AddTimedEffect.atCoord(ART_DemolisherFireMissile, GetUnitX(this.caster), GetUnitY(this.caster), 0.0);
            AddTimedEffect.atUnit(ART_Liquidfire, this.caster, "origin", returnDuration(lvl));
        }
    }

    function onCast() {
        SunField.new(SpellEvent.CastingUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUN_FIRE_STORM, onCast);
    }

}
//! endzinc
