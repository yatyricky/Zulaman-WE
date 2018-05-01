//! zinc
library EternalGuardian {

    struct UnitMapper {
        static HandleTable ht;
        unit k;
        unit v;

        method getValue() -> unit {
            return this.v;
        }

        method dead() {
            thistype.ht.flush(this.k);
            this.k = null;
            this.v = null;
            this.deallocate();
        }

        static method inst(unit u) -> thistype {
            if (thistype.ht.exists(u)) {
                return thistype.ht[u];
            } else {
                return 0;
            }
        }

        static method create(unit k, unit v) -> thistype {
            thistype this = thistype.allocate();
            this.k = k;
            this.v = v;
            thistype.ht[k] = this;
            return this;
        }

        static method onInit() {
            thistype.ht = HandleTable.create();
        }

    }

    function eternalGuardianDeath(unit u) {
        UnitMapper d;
        if (UnitMapper.inst(u) != 0) {
            d = UnitMapper.inst(u);
            d.dead();
        }
    }

    function damaged() {
        UnitMapper d;
        unit caster;
        integer points = 1;
        if (UnitMapper.inst(DamageResult.source) != 0) {
            d = UnitMapper.inst(DamageResult.source);
            if (GetUnitAbilityLevel(DamageResult.source, BID_ETERNAL_GUARDIAN_FRENZY) > 0) {
                points = 2;
            }
            ModUnitMana(d.getValue(), points);
        }
    }

    function onCast() {
        Point p = EternalGuardianSpots.get(GetRandomInt(0, EternalGuardianSpots.size() - 1));
        unit u = CreateUnit(Player(MOB_PID), UTID_ETERNAL_GUARDIAN, p.x, p.y, GetRandomReal(0, 359.99));
        UnitMapper.create(u, SpellEvent.CastingUnit);
    }

    function onInit() {
        RegisterDamagedEvent(damaged);
        RegisterSpellEffectResponse(SID_ETERNAL_GUARDIAN, onCast);
        RegisterUnitDeath(eternalGuardianDeath);
    }

}
//! endzinc
