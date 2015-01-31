//! zinc
library StrangeWand requires NefUnion, SpellEvent, BuffSystem {
#define ART_TARGET "Doodads\\Cinematic\\EnergyField\\EnergyField.mdl"
//"Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl"

    struct StrangeWand {
        private timer tm;
        private real x, y;
        private integer count;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.deallocate();
        }
        
        private method doJob() {
            unit tu;
            Buff buf;
            integer ex;
            GroupUnitsInArea(ENUM_GROUP, this.x, this.y, 350.0);
            tu = FirstOfGroup(ENUM_GROUP);
            while (tu != null) {
                GroupRemoveUnit(ENUM_GROUP, tu);
                if (!IsUnitDummy(tu) && !IsUnitDead(tu)) {
                    // main logic happens here
                    buf = BuffSlot[tu].top;
                    while (buf != 0) {
                        if (buf.bd.bt.buffCate == BUFF_MAGE) {
                            if (buf.bd.tick == -1) {
                                if (TimerGetRemaining(buf.tm) < 0.6) {
                                    buf.reRunForLasting(0.7);
                                }
                            } else {
                                ex = R2I(0.5 / buf.bd.interval);
                                if (buf.bd.tick < (ex + 2)) {
                                    buf.bd.tick += (ex + 1);
                                }
                            }
                        }
                        buf = buf.next;
                    }
                }
                tu = FirstOfGroup(ENUM_GROUP);
            }
            tu = null;
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.doJob();
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
        }
        
        static method start(real x, real y) {
            thistype this = thistype.allocate();
            this.x = x;
            this.y = y;
            this.count = 30;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.doJob();
            TimerStart(this.tm, 0.5, true, function thistype.run);
        }
    }

    function onCast() {
        AddTimedEffect.atCoord(ART_TARGET, SpellEvent.TargetX, SpellEvent.TargetY, 15.0);
        StrangeWand.start(SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_STRANGE_WAND, onCast);
    }
#undef ART_TARGET
}
//! endzinc


//    function onCast() {
//        Buff current = BuffSlot[SpellEvent.TargetUnit].top;
//        while (current != 0) {
//            if (current.bd.bt.buffCate == BUFF_MAGE) {
//                if (current.bd.tick == -1) {
//                    current.bd.interval *= 2.0;
//                } else {
//                    current.bd.tick *= 2;
//                }
//            }
//            current = current.next;
//        }
//
//        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 1.0);
//    }
