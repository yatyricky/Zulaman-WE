//! zinc
library Enigma requires ItemAttributes, DamageSystem {
#define ART "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
    HandleTable ht;

    struct EnigmaData {
        private static HandleTable enigtable;
        integer life;
        integer str;
        
        static method operator[] (item it) -> thistype {
            thistype this;
            if (!thistype.enigtable.exists(it)) {
                this = thistype.allocate();
                thistype.enigtable[it] = this;
                this.life = 0;
                this.str = 0;
            } else {
                this = thistype.enigtable[it];
            }
            return this;
        }
        
        private static method onInit() {
            thistype.enigtable = HandleTable.create();
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        EnigmaData ed = EnigmaData[it];
        up.damageTaken -= 0.05 * fac;
        up.damageDealt += 0.05 * fac;
        up.ModSpeed(45 * fac);
        up.damageGoesMana += 0.04 * fac;
        if (fac == 1) {
            ed.str = 4 * GetHeroLevel(u);
            ed.life = Rounding(0.05 * GetUnitState(u, UNIT_STATE_MAX_LIFE));
        }
        up.ModStr(ed.str * fac);
        up.ModLife(ed.life * fac);
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    function onCast() {
        SetUnitX(SpellEvent.CastingUnit, GetUnitX(SpellEvent.TargetUnit));
        SetUnitY(SpellEvent.CastingUnit, GetUnitY(SpellEvent.TargetUnit));
        AddTimedEffect.atUnit(ART, SpellEvent.CastingUnit, "origin", 1.0);
    }
    
    function lvledup() -> boolean {
        unit u = GetTriggerUnit();
        integer i;
        item tmpi;
        ItemPropModType ipmt;
        if (ht.exists(u)) {
            if (ht[u] > 0) {
                ipmt = action;
                i = 0;
                while (i < 6) {
                    tmpi = UnitItemInSlot(u, i);
                    if (GetItemTypeId(tmpi) == ITIDENIGMA) {
                        ipmt.evaluate(u, tmpi, -1);
                        ipmt.evaluate(u, tmpi, 1);
                    }
                    i += 1;
                }
            }
        }
        return false;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDENIGMA, action);
        RegisterSpellEffectResponse(SIDENIGMA, onCast);    
        TriggerAnyUnit(EVENT_PLAYER_HERO_LEVEL, function lvledup);
    }
#undef ART
}
//! endzinc
