//! zinc
library MarrowSqueeze requires CastingBar, UnitProperty, HeathenGlobal {
constant string  ART  = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl";
constant integer BUFF_ID = 'A04Q';

    function returnDamage(integer lvl, real sp) -> real {
        return 180 + sp * 0.92;
    }

    function returnAbsorbMultiplier(integer lvl) -> real {
        return 0.05 * lvl;
    }
    
    function returnMaxhpIncre(integer lvl) -> real {
        return 0.25 * lvl;
    }
    
    function onEffect(Buff buf) {}
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(0 - buf.bd.i0);
    }

    function response(CastingBar cd) {
        integer lvl = GetUnitAbilityLevel(cd.caster, SID_MARROW_SQUEEZE);
        real dmg = returnDamage(lvl, UnitProp.inst(cd.caster, SCOPE_PREFIX).SpellPower());
        integer incre;
        real heal;
        real lengthen;
        Buff buf, swpain;
        AddTimedEffect.atUnit(ART, cd.target, "origin", 0.3);
        DamageTarget(cd.caster, cd.target, dmg, SpellData.inst(SID_MARROW_SQUEEZE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
        
        // equiped Anathema
        if (UnitHasItemOfTypeBJ(cd.caster, ITID_ANATHEMA) == true) {
            swpain = BuffSlot[cd.target].getBuffByBid(PAIN_DEBUFF_ID);
            if (swpain != 0) {
                lengthen = ItemExAttributes.getUnitAttrVal(cd.caster, IATTR_CT_PAIN, SCOPE_PREFIX);
                swpain.bd.tick += R2I(lengthen / swpain.bd.interval) + 1;
            }
        }
        
        heal = DamageResult.amount * returnAbsorbMultiplier(lvl);
        incre = R2I(heal);
        
//BJDebugMsg("To increase by " + I2S(incre));
        
        buf = Buff.cast(cd.caster, cd.caster, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10;
        if (buf.bd.i0 == 0) { // i0 = current incre/ i1 = max / r0 = original
            buf.bd.r0 = GetUnitState(buf.bd.target, UNIT_STATE_MAX_LIFE);
//BJDebugMsg("Init once " + I2S(buf.bd.i1));
        }
        buf.bd.i1 = R2I(buf.bd.r0 * returnMaxhpIncre(lvl));
        if (buf.bd.i0 + incre > buf.bd.i1) {
            incre = buf.bd.i1 - buf.bd.i0;
//BJDebugMsg("Overflow " + I2S(incre));
        }
        if (incre > 0) {
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(incre);
            buf.bd.i0 += incre;
//BJDebugMsg("Do it ");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        HealTarget(cd.caster, cd.caster, heal, SpellData.inst(SID_MARROW_SQUEEZE, SCOPE_PREFIX).name, 0.0, false);
    }
    
    function onChannel() {
        CastingBar.create(response).setVisuals(ART_IllidanMissile).setSound(castSound).launch();
    }
    
    integer castSound;

    function onInit() {
        castSound = DefineSound("Abilities\\Spells\\Undead\\UndeadMine\\MineDomeLoop1.wav", 1869, true, false);
        RegisterSpellChannelResponse(SID_MARROW_SQUEEZE, onChannel);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }


}
//! endzinc
