//! zinc
library MarkOfAgony requires DamageSystem {

    struct MarkOfAgony {
        static HandleTable ht;
        unit caster;
        unit targets[32];
        integer n;

        method destroy() {
            integer i;
            for (0 <= i < this.n) {
                this.targets[i] = null;
            }
            thistype.ht.flush(this.caster);
            this.caster = null;
            this.deallocate();
        }

        method add(unit target) {
            this.targets[this.n] = target;
            this.n += 1;
        }

        method locate(unit target) -> integer {
            integer i = 0;
            integer found = -1;
            while (i < this.n) {
                if (IsUnit(target, this.targets[i])) {
                    found = i;
                    i += this.n;
                } else {
                    i += 1;
                }
            }
            return found;
        }

        method remove(unit target) {
            integer index = this.locate(target);
            if (index != -1) {
                this.n -= 1;
                this.targets[index] = this.targets[this.n];
                this.targets[this.n] = null;
            }
            if (this.n <= 0) {
                this.destroy();
            }
        }

        static method start(unit caster, unit target) -> thistype {
            thistype this;
            if (thistype.ht.exists(caster)) {
                this = thistype.ht[caster];
            } else {
                this = thistype.allocate();
                thistype.ht[caster] = this;
                this.n = 0;
                this.caster = caster;
            }
            this.add(target);
            return this;
        }

        static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function maidOfAgonyDamaged() {
        MarkOfAgony data;
        integer i;
        if (GetUnitTypeId(DamageResult.target) == UTID_MAID_OF_AGONY) {
            if (MarkOfAgony.ht.exists(DamageResult.target)) {
                data = MarkOfAgony.ht[DamageResult.target];
                for (0 <= i < data.n) {
                    DamageTarget(DamageResult.target, data.targets[i], DamageResult.amount * 0.25, SpellData.inst(SID_MARK_OF_AGONY, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                }
            }
        }
    }

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        MarkOfAgony data = buf.bd.i0;
        data.remove(buf.bd.target);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_MARK_OF_AGONY);
        MarkOfAgony data = MarkOfAgony.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
        buf.bd.tick = -1;
        buf.bd.interval = 12;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_BANISH_TARGET, buf, "origin");
        }
        buf.bd.i0 = data;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MARK_OF_AGONY, onCast);
        BuffType.register(BID_MARK_OF_AGONY, BUFF_MAGE, BUFF_NEG);
        RegisterDamagedEvent(maidOfAgonyDamaged);
    }
}
//! endzinc
