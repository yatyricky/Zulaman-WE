//! zinc
library FilthyTentacle requires BuffSystem {

    constant integer SPEED = 20;
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
    }

    struct FilthyTentacle {
        private timer tm;
        private unit caster, target;
        private vector vo, vt, dir;

        private method destroy() {
            this.vo.destroy();
            this.vt.destroy();
            this.dir.destroy();
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.target = null;
            this.deallocate();
        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (!IsUnitDead(this.target)) {
                // Move target towards the tentacle
                this.vt.reset(GetUnitX(this.target), GetUnitY(this.target), 0);
                this.dir.copy(this.vo);
                this.dir.subtract(this.vt);
                if (this.dir.getLength() < SPEED) {
                    // arrived
                    this.destroy();
                } else {
                    this.dir.setLength(SPEED);
                    this.vt.add(this.dir);
                    SetUnitPosition(this.target, this.vt.x, this.vt.y);
                }

                AddTimedLight.atUnits("BPSE", this.target, this.caster, 0.04);
            }
        }

        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            Buff buf;
            this.caster = caster;
            this.target = target;
            this.tm = NewTimer();
            this.vo = vector.create(GetUnitX(caster), GetUnitY(caster), 0);
            this.vt = vector.create(GetUnitX(target), GetUnitY(target), 0);
            this.dir = vector.create(0, 0, 0);
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.run);

            // slow effect
            buf = Buff.cast(caster, target, BID_FILTHY_TENTACLE_DRAG);
            buf.bd.tick = -1;
            buf.bd.interval = 10;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
            buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.5);
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onCast() {
        FilthyTentacle.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FILTHY_TENTACLE_DRAG, onCast);
        BuffType.register(BID_FILTHY_TENTACLE_DRAG, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
