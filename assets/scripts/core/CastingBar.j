//! zinc
library CastingBar requires SpellEvent, TimerUtils, SpellData, UnitAbilityCD, ZAMCore {
//==============================================================================
//  Usage:
//=========
//  CastingBar.create(response).launch();
//  
//  CastingBar cb = CastingBar.create([response]);
//  cb.haste = [percentage];
//  cb.launch();
//
//  CastingBar.create(response).channel([nodes]);
//==============================================================================
    constant integer PROGRESS_BAR_X = -10;
    constant integer PROGRESS_BAR_Y = -100;
    constant integer PROGRESS_BAR_Z = 30;
    constant real PROGRESS_BAR_SX = 1.0;
    constant real PROGRESS_BAR_SY = 0.45;
    constant real PROGRESS_BAR_SZ = 0.45;
    constant integer CAST_MODE_CAST = 0x23459214;
    constant integer CAST_MODE_CHANNEL = 0x32148520;
    constant real UNIT_SIZE = 128.0;
    
    public type CastBarFinishCast extends function(CastingBar);
    
    //Table responseTable;
    HandleTable lastChannelSuccess;
    
    struct DelayedModUnitMana {
        timer tm;
        unit u;
        real amt;
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            ModUnitMana(this.u, this.amt);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        static method new(unit u, real amt) {
            thistype this = thistype.allocate();
            this.u = u;
            this.amt = amt;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }
    
    public struct CastAttachLightning {
        private static location la, lb;
        private timer tm;
        private lightning lt;
        private unit a, b;
        
        method destroy() {
            ReleaseTimer(this.tm);
            DestroyLightning(this.lt);
            this.lt = null;
            this.tm = null;
            this.a = null;
            this.b = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            MoveLocation(thistype.la, GetUnitX(this.a), GetUnitY(this.a));
            MoveLocation(thistype.lb, GetUnitX(this.b), GetUnitY(this.b));
            MoveLightningEx(this.lt, false, /*
                */GetLocationX(thistype.la), GetLocationY(thistype.la), GetLocationZ(thistype.la)+GetUnitFlyHeight(this.a), /*
                */GetLocationX(thistype.lb), GetLocationY(thistype.lb), GetLocationZ(thistype.lb)+GetUnitFlyHeight(this.b));
        }
        
        static method atUnits(string model, unit a, unit b) -> thistype {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            this.a = a;
            this.b = b;
            MoveLocation(thistype.la, GetUnitX(this.a), GetUnitY(this.a));
            MoveLocation(thistype.lb, GetUnitX(this.b), GetUnitY(this.b));
            this.lt = AddLightningEx(model, false, /*
                */GetLocationX(thistype.la), GetLocationY(thistype.la), GetLocationZ(thistype.la)+GetUnitFlyHeight(this.a), /*
                */GetLocationX(thistype.lb), GetLocationY(thistype.lb), GetLocationZ(thistype.lb)+GetUnitFlyHeight(this.b));
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.run);
            return this;
        }
        
        private static method onInit() {
            thistype.la = Location(0.0, 0.0);
            thistype.lb = Location(0.0, 0.0);
        }
    }

    public struct CastingBar {
        static HandleTable ht;
        SpellData sd;
        CastBarFinishCast finishResponse;
        CastBarFinishCast counteredResponse;
        unit caster, target;
        real targetX, targetY;
        effect bar;
        timer tm, visualTimer;
        ListObject/*<int* effect>*/ visuals;
        real visualElapsed;
        real haste, cost, cast;
        boolean success;
        integer channeling; // 0 not channeling; 1 normal; 2 uncounterable
        integer lvl;
        integer nodes;
        integer castMode;
        
        sound castingSound;
        
        CastAttachLightning l0;
        effect e0, e1;
        
        integer extraData;
        
        method destroy() {
            NodeObject iter = this.visuals.head;
            while (iter != 0) {
                DestroyEffect(Int2Eff(iter.data));
                iter = iter.next;
            }
            this.visuals.destroy();
            ReleaseTimer(this.tm);
            ReleaseTimer(this.visualTimer);
            BlzSetSpecialEffectScale(this.bar, 0);
            DestroyEffect(this.bar);
            if (this.e0 != null) {DestroyEffect(this.e0); this.e0 = null;}
            if (this.e1 != null) {DestroyEffect(this.e1); this.e1 = null;}
            if (this.l0 != 0) {this.l0.destroy(); this.l0 = 0;}
            thistype.ht.flush(this.caster);
            this.tm = null;
            this.bar = null;
            this.caster = null;
            this.target = null;
            this.castingSound = null;
            this.deallocate();
        }
        
        static method create(CastBarFinishCast cbfc) -> thistype {
            thistype this = thistype.allocate();
            this.lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SpellEvent.AbilityId);
            this.haste = 0.0;
            this.finishResponse = cbfc;
            this.counteredResponse = 0;
            this.sd = SpellData.inst(SpellEvent.AbilityId, SCOPE_PREFIX);
            this.cost = this.sd.Cost(this.lvl);
            this.cast = this.sd.Cast(this.lvl);
            this.caster = SpellEvent.CastingUnit;
            if (this.sd.otp == ORDER_TYPE_TARGET) {
                this.target = SpellEvent.TargetUnit;
            } else {
                this.target = null;
            }
            this.targetX = SpellEvent.TargetX;
            this.targetY = SpellEvent.TargetY;
            
            this.e0 = null;
            this.e1 = null;
            this.l0 = 0;
            
            this.castingSound = null;
            this.visuals = ListObject.create();
            this.visualElapsed = 0.0;
            
            return this;
        }
    
        static method castingRunning() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.success = true;
            if (this.target != null) {
                if (IsUnitDead(this.target)) {
                    this.success = false;
                }
            }
            IssueImmediateOrderById(this.caster, OID_STOP);
        }
        
        method setSound(integer sndType) -> thistype {
            this.castingSound = RunSoundAtPoint2d(sndType, GetUnitX(this.caster), GetUnitY(this.caster));
            return this;
        }

        method setVisuals(string path) -> thistype {
            integer i = 0;
            real step = bj_PI * 2.0 / (this.lvl + 1);
            effect eff;
            while (i < this.lvl + 1) {
                eff = AddSpecialEffect(path, GetUnitX(this.caster) + UNIT_SIZE * Cos(step * i), GetUnitY(this.caster) + UNIT_SIZE * Sin(step * i));
                BlzSetSpecialEffectRoll(eff, step * i + bj_PI * 0.5);
                this.visuals.push(Eff2Int(eff));
                i += 1;
            }
            eff = null;
            return this;
        }

        method setCounteredCallback(CastBarFinishCast cbfc) -> thistype {
            this.counteredResponse = cbfc;
            return this;
        }

        static method visualRunning() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            real step = bj_PI * 2.0 / (this.lvl + 1);
            real aoff;
            real dis;
            NodeObject iter;
            effect eff;
            this.visualElapsed += 0.04;
            aoff = bj_PI * this.visualElapsed;
            dis = (this.cast - this.visualElapsed) / this.cast * UNIT_SIZE * 0.5 + UNIT_SIZE * 0.5;
            if (dis < 0) {dis = 0;}
            iter = this.visuals.head;
            while (iter != 0) {
                eff = IntRefEff(iter.data);
                BlzSetSpecialEffectRoll(eff, step * i + aoff + bj_PI * 0.5);
                BlzSetSpecialEffectPosition(eff, GetUnitX(this.caster) + dis * Cos(step * i + aoff), GetUnitY(this.caster) + dis * Sin(step * i + aoff), GetUnitZ(this.caster) + 40);
                iter = iter.next;
                i += 1;
            }
            eff = null;
        }
        
        method launch() {
            real mscale = ModelInfo.get(GetUnitTypeId(this.caster), "CastingBar: 188").scale;
            thistype.ht[this.caster] = this;
            this.channeling = this.sd.level;
            this.castMode = CAST_MODE_CAST;
            this.success = false;
            this.bar = AddSpecialEffect(ART_Progressbar, GetUnitX(this.caster) + PROGRESS_BAR_X, GetUnitY(this.caster) + PROGRESS_BAR_Y * mscale);
            BlzSetSpecialEffectZ(this.bar, GetUnitZ(this.caster) + 40);
            BlzSetSpecialEffectColorByPlayer(this.bar, GetOwningPlayer(this.caster));
            BlzSetSpecialEffectScale(this.bar, mscale);
            this.cast = (this.cast - this.haste) / (1.0 + UnitProp.inst(this.caster, SCOPE_PREFIX).SpellHaste());
            if (this.cast <= 0.01) {this.cast = 0.01;}
            BlzSetSpecialEffectTimeScale(this.bar, 1.0 / this.cast);
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, this.cast, false, function thistype.castingRunning);

            this.visualTimer = NewTimer();
            SetTimerData(this.visualTimer, this);
            TimerStart(this.visualTimer, 0.04, true, function thistype.visualRunning);
        }
        
        private static method channelRunning() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.finishResponse.evaluate(this);
            this.nodes -= 1;
            if (this.nodes < 1) {
                this.success = true;
                IssueImmediateOrderById(this.caster, OID_STOP);
            }
        }
        
        method channel(integer nodes) {
            real mscale = ModelInfo.get(GetUnitTypeId(this.caster), "CastingBar: 221").scale;
            thistype.ht[this.caster] = this;
            this.channeling = this.sd.level;
            this.castMode = CAST_MODE_CHANNEL;
            this.success = false;
            this.bar = AddSpecialEffect(ART_Progressbar, GetUnitX(this.caster) + PROGRESS_BAR_X, GetUnitY(this.caster) + PROGRESS_BAR_Y * mscale);
            BlzSetSpecialEffectZ(this.bar, GetUnitZ(this.caster) + 40);
            BlzSetSpecialEffectColorByPlayer(this.bar, GetOwningPlayer(this.caster));
            BlzSetSpecialEffectScale(this.bar, mscale);
            BlzSetSpecialEffectTime(this.bar, 1.0);
            DelayedModUnitMana.new(SpellEvent.CastingUnit, 0 - this.cost);
            this.cast = (this.cast - this.haste);
            if (this.cast <= 0.01) {this.cast = 0.01;}
            BlzSetSpecialEffectTimeScale(this.bar, -1.0 / this.cast);
            this.nodes = nodes;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, this.cast / this.nodes, true, function thistype.channelRunning);

            this.visualTimer = NewTimer();
            SetTimerData(this.visualTimer, this);
            TimerStart(this.visualTimer, 0.04, true, function thistype.visualRunning);
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function endcast() {
        CastingBar cb = CastingBar.ht[SpellEvent.CastingUnit];
        if (cb != 0) {
            cb.channeling = 0;
            
            // stop sound if any
            if (cb.castingSound != null) {
                ReleaseSound(cb.castingSound);
            }
            cb.castingSound = null;
            
            if (cb.castMode == CAST_MODE_CAST) {
                lastChannelSuccess[SpellEvent.CastingUnit] = 0;
                if (!cb.success) {
                    SimError(GetOwningPlayer(SpellEvent.CastingUnit), "Spell Countered");
                    if (cb.counteredResponse != 0) {
                        cb.counteredResponse.evaluate(cb);
                    }
                } else if (GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MANA) < cb.cost) {
                    SimError(GetOwningPlayer(SpellEvent.CastingUnit), "Not Enough Mana");
                } else {
                    lastChannelSuccess[SpellEvent.CastingUnit] = 1;
                    UnitAbilityCD.start(SpellEvent.CastingUnit, SpellEvent.AbilityId);
                    SetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MANA, GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MANA) - cb.cost);
                    cb.finishResponse.evaluate(cb);
                }
            } else if (cb.castMode == CAST_MODE_CHANNEL) {
                lastChannelSuccess[SpellEvent.CastingUnit] = 1;
                UnitAbilityCD.start(SpellEvent.CastingUnit, SpellEvent.AbilityId);
                if (!cb.success) {
                    SimError(GetOwningPlayer(SpellEvent.CastingUnit), "Spell Countered");
                }
                cb.nodes = -1;
                cb.finishResponse.evaluate(cb);
            }
            cb.destroy();
        }
    }
    
    function spellEffect() {
        lastChannelSuccess[SpellEvent.CastingUnit] = 1;
        UnitAbilityCD.start(SpellEvent.CastingUnit, SpellEvent.AbilityId);
    }
    
    public function IsLastSpellSuccess(unit u) -> boolean {
        return lastChannelSuccess[SpellEvent.CastingUnit] == 1;
    }
    
    public function CounterSpell(unit u) {
        CastingBar cb = CastingBar.ht[u];
        if (cb != 0) {
            if (cb.channeling < 2) {
                UnitAbilityCD.make(u, cb.sd.sid, cb.sd.CD(GetUnitAbilityLevel(u, cb.sd.sid)) + 5.0);
                IssueImmediateOrderById(u, OID_STOP);
            }
        }
    }
    
    public function IsUnitChanneling(unit whichUnit) -> boolean {
        if (CastingBar.ht.exists(whichUnit)) {
            return (CastingBar(CastingBar.ht[whichUnit]).channeling > 0);
        } else {
            return false;
        }
    }
    
    public function IsUnitChannelingCounterable(unit whichUnit) -> boolean {
        if (CastingBar.ht.exists(whichUnit)) {
            return (CastingBar(CastingBar.ht[whichUnit]).channeling == 1);
        } else {
            return false;
        }
    }
    
    public function UnitCanUse(unit source, integer abil) -> boolean {
        return (GetUnitAbilityLevel(source, abil) > 0 && !UnitAbilityCD.isCooling(source, abil) && GetUnitState(source, UNIT_STATE_MANA) >= SpellData.inst(abil, SCOPE_PREFIX).Cost(GetUnitAbilityLevel(source, abil)));
    }

    function onInit() {
        RegisterSpellEffectResponse(0, spellEffect);
        RegisterSpellEndCastResponse(0, endcast);
        lastChannelSuccess = HandleTable.create();
    }

}
//! endzinc
