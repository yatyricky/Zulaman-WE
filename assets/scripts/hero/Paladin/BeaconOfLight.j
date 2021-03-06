//! zinc
library BeaconOfLight requires BuffSystem, GroupUtils, DamageSystem {

    public struct BeaconOfLight {
        private static HandleTable ht;
        private static thistype current;
        private unit primary;
        private group extras;
        private unit u, from;
        private real amount;
        private string art;
        
        method newPrimary(unit np) {
            Buff buf;
            if (this.primary != null) {
                //print(SCOPE_PREFIX+"already has a primary beacon");
                if (!IsUnitDead(this.primary) && !IsUnit(this.primary, np)) {
                    //print(SCOPE_PREFIX+"and he's alive");
                    buf = BuffSlot[this.primary].getBuffByBid(BID_BEACON_OF_LIGHT);
                    if (buf == 0) {
                        print(SCOPE_PREFIX+">|cffff0000logical error|r, should have the buff");
                    } else {
                        BuffSlot[this.primary].dispelByBuff(buf);
                        buf.destroy();
                    }
                }
            }
            this.primary = np;
            //BJDebugMsg("New Primary = " + GetUnitNameEx(this.primary));
        }
        
        method primaryRemove() {
            //BJDebugMsg("set null first" + GetUnitNameEx(this.primary));
            this.primary = null;
        }
        
        private static method healExtras() {
            unit e = GetEnumUnit();
            HealTarget(thistype.current.u, e, thistype.current.amount, SpellData.inst(SID_BEACON_OF_LIGHT, SCOPE_PREFIX).name, -3.0, false);
            AddTimedLight.atUnitsZ("HWPB", thistype.current.from, 10.0, e, 10.0, 0.5);
            if (thistype.current.art != "") {
                AddTimedEffect.atUnit(thistype.current.art, e, "origin", 0.2);
            } else {
                AddTimedEffect.atPos(ART_FAERIE_DRAGON_MISSILE, GetUnitX(e), GetUnitY(e), GetUnitZ(e) + 24.0, 0, 3);
            }
            e = null;
        }
        
        method healBeacons(unit from, real amt, string art) {
            //BJDebugMsg("Heal target = " + GetUnitNameEx(from) + ", primary = " + GetUnitNameEx(this.primary));
            this.amount = (GetUnitAbilityLevel(this.u, SID_BEACON_OF_LIGHT) * 0.15 + 0.35) * amt;
            this.from = from;
            this.art = art;
            if (!IsUnit(from, this.primary) && this.primary != null) {
                HealTarget(this.u, this.primary, this.amount, SpellData.inst(SID_BEACON_OF_LIGHT, SCOPE_PREFIX).name, -3.0, false);
                AddTimedLight.atUnitsZ("HWPB", from, 10.0, this.primary, 10.0, 0.5);
                if (art != "") {
                    AddTimedEffect.atUnit(art, this.primary, "origin", 0.2);
                } else {
                    AddTimedEffect.atPos(ART_FAERIE_DRAGON_MISSILE, GetUnitX(this.primary), GetUnitY(this.primary), GetUnitZ(this.primary) + 24.0, 0, 3);
                }
            }
            if (FirstOfGroup(this.extras) != null) {
                thistype.current = this;
                ForGroup(this.extras, function thistype.healExtras);
            }
        }
        
        method addExtras(unit newextra) {
            if (!IsUnit(newextra, this.primary)) {
                GroupAddUnit(this.extras, newextra);
            }
        }
        
        method removeExtras(unit newextra) {
            if (IsUnitInGroup(newextra, this.extras)) {
                GroupRemoveUnit(this.extras, newextra);
            }
        }
        
        static method operator[] (unit u) -> thistype {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                //BJDebugMsg("New ��");
                thistype.ht[u] = this;
                this.primary = null;
                this.extras = NewGroup();
                GroupRefresh(this.extras);
                this.u = u;
            } else {
                this = thistype.ht[u];
            }
            return this;
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function onEffect(Buff buf) {
        //BJDebugMsg("Ҫִ�а�,�µ�Ŀ����"+GetUnitNameEx(buf.bd.target));
        BeaconOfLight[buf.bd.caster].newPrimary(buf.bd.target);
    }
    
    function onRemove(Buff buf) {
        BeaconOfLight[buf.bd.caster].primaryRemove();
    }
    
    function ondamageresponse() {
        Buff buf;
        if (GetUnitAbilityLevel(DamageResult.target, BID_BEACON_OF_LIGHT) > 0) {
            if (DamageResult.amount > GetWidgetLife(DamageResult.target)) {
                buf = BuffSlot[DamageResult.target].getBuffByBid(BID_BEACON_OF_LIGHT);
                BuffSlot[DamageResult.target].dispelByBuff(buf);
                buf.destroy();
                DamageResult.amount = 0.0;
                AddTimedEffect.atUnit(ART_ANGEL, DamageResult.target, "origin", 0.2);
            }            
        }
    }

    function onCast() {        
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_BEACON_OF_LIGHT);
        buf.bd.interval = 10 + 5 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_BEACON_OF_LIGHT);
        buf.bd.tick = -1;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BEACON_OF_LIGHT, onCast);
        RegisterOnDamageEvent(ondamageresponse);
        BuffType.register(BID_BEACON_OF_LIGHT, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
