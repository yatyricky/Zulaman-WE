//! zinc
library MarrowSqueeze requires CastingBar, UnitProperty, Anathema, HeathenGlobal {
#define ART "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl"
#define BUFF_ID 'A04Q'

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
        UnitProp[buf.bd.target].ModLife(0 - buf.bd.i0);
    }

    function response(CastingBar cd) {
        integer lvl = GetUnitAbilityLevel(cd.caster, SIDMARROWSQUEEZE);
        real dmg = returnDamage(lvl, UnitProp[cd.caster].SpellPower());
        integer incre;
        real heal;
        Buff buf, swpain;
        AddTimedEffect.atUnit(ART, cd.target, "origin", 0.3);
        DamageTarget(cd.caster, cd.target, dmg, SpellData[SIDMARROWSQUEEZE].name, false, true, false, WEAPON_TYPE_WHOKNOWS);  
        
        // equiped Anathema
        if (HasAnathema(cd.caster)) {
            swpain = BuffSlot[cd.target].getBuffByBid(PAIN_DEBUFF_ID);
            if (swpain != 0) {
                swpain.bd.tick += 1;
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
            UnitProp[buf.bd.target].ModLife(incre);
            buf.bd.i0 += incre;
//BJDebugMsg("Do it ");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        HealTarget(cd.caster, cd.caster, heal, SpellData[SIDMARROWSQUEEZE].name, 0.0);
    }
    
    function onChannel() {
        CastingBar.create(response).setSound(castSound).launch();
    }
    
    integer castSound;

    function onInit() {
        castSound = DefineSound("Abilities\\Spells\\Undead\\UndeadMine\\MineDomeLoop1.wav", 1869, true, false);
        RegisterSpellChannelResponse(SIDMARROWSQUEEZE, onChannel);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef BUFF_ID
#undef ART
}
//! endzinc
