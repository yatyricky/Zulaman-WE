//! zinc
library PsychicLink {

    struct PsychicLink {
        private timer tm;
        private unit caster;
        private unit target1, target2;
        private integer ctr;

        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.target1 = null;
            this.target2 = null;
            this.deallocate();
        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.ctr -= 1;
            
            if (this.ctr == 0) {
                this.destroy();
            } else {
                if (!IsUnitDead(this.target1) && !IsUnitDead(this.target2)) {
                    if (GetDistance.units2d(this.target1, this.target2) > GodOfDeathGlobalConst.psychicLinkRange) {
                        ModUnitMana(this.caster, 1);
                        AddTimedLight.atUnits("MBUR", target1, target2, 1.1);
                    } else {
                        AddTimedLight.atUnits("MBUR", target1, target2, 1.1);
                    }
                } else {
                    this.destroy();
                }
            }
            
        }

        static method start(unit caster, unit target1, unit target2) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            this.caster = caster;
            this.target1 = target1;
            this.target2 = target2;
            this.ctr = 10;
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);

            AddTimedLight.atUnits("MBUR", target1, target2, 1.1);
        }
    }
    
    function onCast() {
        unit near = PlayerUnits.getNearest(SpellEvent.CastingUnit);
        unit far = PlayerUnits.getFarest(SpellEvent.CastingUnit);
        if (!IsUnit(near, far)) {
            PsychicLink.start(SpellEvent.CastingUnit, near, far);
        }
        near = null;
        far = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID, onCast);
    }
}
//! endzinc
