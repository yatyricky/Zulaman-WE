//! zinc
library VoodooDoll requires DamageSystem {
    
    struct VoodooDoll {
        static thistype lastCast;
        static HandleTable ht;
        static trigger damageTrigger;
        unit caster, target, illusion;
        timer tm;
        
        method destroy() {
            ReleaseTimer(this.tm);
            thistype.ht.flush(this.illusion);
            this.caster = null;
            this.target = null;
            this.illusion = null;
            this.tm = null;
            this.deallocate();
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (this.illusion != null) {
                DamageTarget(this.target, this.illusion, GetUnitState(this.illusion, UNIT_STATE_MAX_LIFE) * 0.1, SpellData.inst(SID_VOODOO_DOLL, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                // HealTarget(this.caster, this.illusion, GetUnitState(this.illusion, UNIT_STATE_MAX_LIFE) * 0.15, SpellData.inst(SID_VOODOO_DOLL, SCOPE_PREFIX).name, 0.0);
            }
        }
    
        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            thistype.lastCast = this;
            this.caster = caster;
            this.target = target;
            this.illusion = null;
            DummyCastByOrderId(caster, SID_VOODOO_DOLL_ILLUSION, 852274, target); // magic number
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
        
        static method onInit() {
            thistype.lastCast = 0;
            thistype.ht = HandleTable.create();
        }
    }
    
    function onCast() {
        VoodooDoll.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }
    
    function newIllusion(unit u) {
        if (IsUnitIllusion(u)) {
            if (VoodooDoll.lastCast == 0) {
                print("|cffff0000Voodoo Doll|r: unable to find correct illusion, killing illusion");
                KillUnit(u);
            } else {
                VoodooDoll.ht[u] = VoodooDoll.lastCast;
                VoodooDoll.lastCast.illusion = u;
                SetUnitPathing(u, false);
                SetUnitX(u, GetUnitX(VoodooDoll.lastCast.target));
                SetUnitY(u, GetUnitY(VoodooDoll.lastCast.target));
                VoodooDoll.lastCast = 0;
            }
        }
    }

    function illusionDeath(unit u) {
        VoodooDoll data;
        if (VoodooDoll.ht.exists(u)) {
            data = VoodooDoll.ht[u];
            data.destroy();
        }
    }

    function illusionDamaged() {
        VoodooDoll data;
        real damage;
        if (IsUnitIllusion(DamageResult.target)) {
            if (VoodooDoll.ht.exists(DamageResult.target)) {
                data = VoodooDoll.ht[DamageResult.target];
                if (!IsUnitDead(data.target)) {
                    DamageTarget(data.caster, data.target, DamageResult.amount, SpellData.inst(SID_VOODOO_DOLL, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    AddTimedEffect.atUnit(ART_ARCANE_TOWER_ATTACK, data.target, "chest", 2.5);
                }
            }
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_VOODOO_DOLL, onCast);
        RegisterUnitEnterMap(newIllusion);
        RegisterDamagedEvent(illusionDamaged);
        RegisterUnitDeath(illusionDeath);
    }
}
//! endzinc
