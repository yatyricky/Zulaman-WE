//! zinc
library VoodooDoll requires CastingBar, Core {
    
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
                DamageTarget(this.caster, this.illusion, GetUnitState(this.illusion, UNIT_STATE_MAX_LIFE) * 0.2, SpellData[SID_VOODOO_DOLL].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                HealTarget(this.caster, this.illusion, GetUnitState(this.illusion, UNIT_STATE_MAX_LIFE) * 0.15, SpellData[SID_VOODOO_DOLL].name, 0.0);
            }
        }
    
        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            thistype.lastCast = this;
            this.caster = caster;
            this.target = target;
            this.illusion = null;
            DummyCast(caster, SID_VOODOO_DOLL_ILLUSION, "illusion", target);
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

    function illusionDamaged(unit u) {
        VoodooDoll data;
        real damage;
        if (VoodooDoll.ht.exists(u)) {
            data = VoodooDoll.ht[u];
            if (!IsUnitDead(data.target)) {
                damage = GetEventDamage() / GetUnitState(u, UNIT_STATE_MAX_LIFE) * GetUnitState(data.target, UNIT_STATE_MAX_LIFE);
                DamageTarget(data.caster, data.target, damage, SpellData[SID_VOODOO_DOLL].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                AddTimedEffect.atUnit(ART_ARCANE_TOWER_ATTACK, data.target, "chest", 2.5);
            }
        } else {
            print("|cffff0000Voodoo Doll|r: unable to find instance!");
        }
    }

    function onInit() {
        RegisterSpellEventResponse(SID_VOODOO_DOLL, onCast);
        RegisterUnitEnterMap(newIllusion);
        RegisterDamagedEvent(illusionDamaged)
        RegisterUnitDeath(illusionDeath);
    }
}
//! endzinc
