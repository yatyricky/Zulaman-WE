//! zinc
library TyraelsMight requires ItemAttributes, DamageSystem {
#define ART_TARGET "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
    HandleTable ht;
    
    function healed() {
        integer i;
        item tmpi;
        if (ht.exists(HealResult.target)) {
            if (ht[HealResult.target] > 0) {
                if (HealResult.abilityName != SpellData[SIDATTACKLL].name && HealResult.abilityName != SpellData[SID_TYRAELS_MIGHT].name) {
                    i = 0;
                    while (i < 6) {
                        tmpi = UnitItemInSlot(HealResult.target, i);
                        if (GetItemTypeId(tmpi) == ITID_TYRAELS_MIGHT) {
                            if (GetItemCharges(tmpi) == 0) {
                                SetItemCharges(tmpi, 2);
                            } else if (GetItemCharges(tmpi) < 20) {
                                SetItemCharges(tmpi, GetItemCharges(tmpi) + 1);
                            }
                        }
                        i += 1;
                    }
                    tmpi = null;
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        
        up.ModStr(20 * fac);
        up.ModArmor(8 * fac);
        up.damageTaken -= 0.08 * fac;
        up.spellTaken -= 0.12 * fac;
        up.ModSpeed(30 * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    function onCast() -> boolean {
        item it = GetManipulatedItem();
        integer charges;
        unit u;
        if (GetItemTypeId(it) == ITID_TYRAELS_MIGHT) {
            charges = GetItemCharges(it);
            u = GetTriggerUnit();
            if (charges > 0) {
                charges += 1;
                HealTarget(u, u, charges * 50.0, SpellData[SID_TYRAELS_MIGHT].name, 0.0);
                SetItemCharges(it, 0);
                AddTimedEffect.atUnit(ART_TARGET, u, "origin", 0.5);
            }
            u = null;
        }
        it = null;
        return false;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_TYRAELS_MIGHT, action);
        RegisterHealedEvent(healed);
        //RegisterSpellEffectResponse(SID_TYRAELS_MIGHT, onCast);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_USE_ITEM, function onCast);
    }
#undef ART_TARGET
}
//! endzinc
