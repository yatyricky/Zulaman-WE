//! zinc
library Vomit requires AggroSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
    }

    function biteByMaggots() {
        Buff buf;
        if (GetUnitTypeId(DamageResult.source) == UTID_VOMIT_MAGGOT) {
            if (DamageResult.isHit && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                buf = Buff.cast(DamageResult.source, DamageResult.target, BID_VOMIT_MAGGOT_BITE);
                buf.bd.tick = -1;
                buf.bd.interval = 10;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
                buf.bd.r0 = 0.45;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }
    
    struct VomitMaggot {
        timer tm;
        unit caster, mis;
        effect eff;
        real tx, ty, dx, dy;
        integer count;

        private method destroy() {
            ReleaseTimer(this.tm);
            AddTimedEffect.atCoord(ART_POISON_SLIME, GetUnitX(this.mis), GetUnitY(this.mis), 0.01);
            KillUnit(this.mis);
            DestroyEffect(this.eff);
            this.caster = null;
            this.tm = null;
            this.mis = null;
            this.eff = null;
            this.deallocate();
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            if (IsInCombat()) {
                SetUnitX(this.mis, GetUnitX(this.mis) + this.dx);
                SetUnitY(this.mis, GetUnitY(this.mis) + this.dy);
                this.count -= 1;
                if (this.count <= 0) {
                    CreateUnit(Player(MOB_PID), UTID_VOMIT_MAGGOT, GetUnitX(this.mis), GetUnitY(this.mis), GetRandomReal(0.0, 359.00));

                    for (0 <= i < PlayerUnits.n) {
                        if (GetDistance.units(PlayerUnits.units[i], this.mis) < 250.0) {
                            DamageTarget(this.caster, PlayerUnits.units[i], 550.0, SpellData.inst(SID_VOMIT, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                        }
                    }

                    this.destroy();
                }
            } else {
                this.destroy();
            }
        }
        
        static method start(unit caster, real tx, real ty) {
            thistype this = thistype.allocate();
            real dis;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);

            this.caster = caster;
            this.mis = CreateUnit(Player(MOB_PID), DUMMY_ID, GetUnitX(caster), GetUnitY(caster), GetUnitFacing(caster));
            this.eff = AddSpecialEffectTarget(ART_POISON_SLIME, this.mis, "origin");
            this.tx = tx;
            this.ty = ty;
            dis = GetDistance.unitCoord(caster, tx, ty);
            this.dx = 25.0 * (tx - GetUnitX(caster)) / dis;
            this.dy = 25.0 * (ty - GetUnitY(caster)) / dis;
            this.count = Rounding(dis / 25.0);

            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }
    
    function response(CastingBar cd) {
        real tx, ty;
        real face = GetUnitFacing(cd.caster) * bj_DEGTORAD;
        tx = Cos(face) * 350 + GetUnitX(cd.caster) + GetRandomReal(-150, 150);
        ty = Sin(face) * 350 + GetUnitY(cd.caster) + GetRandomReal(-150, 150);
        VomitMaggot.start(cd.caster, tx, ty);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        cb.channel(9);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_VOMIT, onChannel);
        RegisterDamagedEvent(biteByMaggots);
        BuffType.register(BID_VOMIT_MAGGOT_BITE, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
