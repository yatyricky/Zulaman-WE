//! zinc
library SpellTransfer requires BuffSystem, SpellEvent, UnitProperty {
//#define BUFF_ID 'A012'

    //function oneffect(Buff buf) {
    //    UnitProp[buf.bd.target].spellTaken += buf.bd.r0;
    //}
    //
    //function onremove(Buff buf) {
    //    UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
    //}
    
    function returnNumberOfDispel(integer lvl) -> integer {
        if (lvl < 3) {
            return lvl;
        } else {
            return 999;
        }
    }

    function onCast() {
        Buff buf, tmp;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSPELLTRANSFER);
        integer num = returnNumberOfDispel(lvl);
        BuffSlot bl;
        integer i;
        unit t;
        if (!IsUnitEnemy(SpellEvent.TargetUnit, GetOwningPlayer(SpellEvent.CastingUnit))) {
            //BJDebugMsg("my friend?");
            //BJDebugMsg(I2S(buf));
            //if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSPELLTRANSFER) > 1) {
            i = 0;
            while (i < num) {
                buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_NEG);
                if (buf != 0) {
                    if (!IsUnitDead(buf.bd.caster)) {     
                        //BJDebugMsg("negative buff catched");
                        bl = BuffSlot[buf.bd.caster];
                        tmp = bl.getBuffByBid(buf.bd.bt.bid);
                        if (tmp != 0) {
                            //BJDebugMsg("removing duplicated buff");
                            tmp.onRemove();
                            tmp.destroy();
                        }
                        buf.bd.target = buf.bd.caster;
                        buf.bd.caster = SpellEvent.CastingUnit;
                        buf.refresh();
                        bl.push(buf);
                        
                        DamageTarget(SpellEvent.CastingUnit, buf.bd.target, 100 + UnitProp[SpellEvent.CastingUnit].SpellPower(), SpellData[SIDSPELLTRANSFER].name, false, true, false, WEAPON_TYPE_WHOKNOWS);  
                    }
                } else {
                    i += 999;
                }
                i += 1;
            }
            //}
        } else {
            //BJDebugMsg("positive buff removed");
            //if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSPELLTRANSFER) > 2) {
            //    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            //    buf.bd.tick = -1;
            //    buf.bd.interval = 6.0;
            //    UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
            //    buf.bd.r0 = 0.06;
            //    buf.bd.boe = oneffect;
            //    buf.bd.bor = onremove;
            //    buf.run();
            //}
            i = 0;
            while (i < num) {
                buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_POS);
                if (buf != 0) {                        
                    DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 100 + UnitProp[SpellEvent.CastingUnit].SpellPower(), SpellData[SIDSPELLTRANSFER].name, false, true, false, WEAPON_TYPE_WHOKNOWS);  
                    
                    //BJDebugMsg("positive buff catched");
                    bl = BuffSlot[SpellEvent.CastingUnit];
                    tmp = bl.getBuffByBid(buf.bd.bt.bid);
                    if (tmp != 0) {
                        //BJDebugMsg("removing duplicated buff");
                        tmp.onRemove();
                        tmp.destroy();
                    }
                    buf.bd.caster = SpellEvent.CastingUnit;
                    buf.bd.target = SpellEvent.CastingUnit;
                    buf.refresh();
                    bl.push(buf);
                    SetLastStolen(SpellEvent.CastingUnit, buf);
                }
            }
        }
        AddTimedEffect.atUnit(ART_SPELLSTEAL, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onCast1() {
        BuffSlot bl;
        Buff tmp;
        Buff buf = GetLastStolen(SpellEvent.CastingUnit);
        if (buf != 0) {
            BuffSlot[SpellEvent.CastingUnit].dispelByBuff(buf);
            bl = BuffSlot[SpellEvent.TargetUnit];
            tmp = bl.getBuffByBid(buf.bd.bt.bid);
            if (tmp != 0) {
                //BJDebugMsg("removing duplicated buff");
                tmp.onRemove();
                tmp.destroy();
            }
            buf.bd.caster = SpellEvent.CastingUnit;
            buf.bd.target = SpellEvent.TargetUnit;
            buf.refresh();
            bl.push(buf);
            SetLastStolen(SpellEvent.CastingUnit, 0);
        }
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SIDSPELLTRANSFER, onCast);
        RegisterSpellEffectResponse(SIDINTELLIGENCECHANNEL, onCast1);
    }
//#undef BUFF_ID
}
//! endzinc
