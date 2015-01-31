//! zinc
library VoodooVial requires ItemAttributes, DamageSystem {
#define BUFF_ID 'A06O'
#define MISSILE "Abilities\\Spells\\Other\\AcidBomb\\BottleMissile.mdl"
    HandleTable ht;
    integer bugs[];
    integer bugsn;
    
    struct AuroIncreaseCharges {
        private static HandleTable ht;
        private timer tm;
        private item it;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer current = GetItemCharges(this.it);
            if (current < 5) {
                SetItemCharges(this.it, current + 1);
            }
        }
    
        static method start(item it) {
            thistype this;
            if (!thistype.ht.exists(it)) {
                this = thistype.allocate();
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                thistype.ht[it] = this;
                this.it = it;
                TimerStart(this.tm, 30.0, true, function thistype.run);
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_VOODOO_VIAL].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.5);
    }

    function onRemove(Buff buf) {}
    
    function damaged() {
        Buff buf;
        integer i;
        integer charges;
        item tmpi;
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && !DamageResult.isPhyx) {
                    if (GetRandomInt(0, 99) < 10) {
                        i = 0;
                        charges = 0;
                        while (i < 6) {
                            tmpi = UnitItemInSlot(DamageResult.source, i);
                            if (GetItemTypeId(tmpi) == ITID_VOODOO_VIAL) {
                                charges += GetItemCharges(tmpi);
                            }
                            i += 1;
                        }
                        tmpi = null;
                    
                        buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID);
                        buf.bd.interval = 2.0 / (1.0 + UnitProp[buf.bd.caster].SpellHaste());
                        buf.bd.tick = Rounding(10.0 / buf.bd.interval);
                        buf.bd.r0 = charges * 9.5 + 3.0;
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
                        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.5);
                    }
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        
        up.ModInt(14 * fac);
        up.ModMana(250 * fac);
        up.spellCrit += 0.03 * fac;
        up.spellHaste += 0.07 * fac;
        //up.ml += 0.1 * fac;
        
        AuroIncreaseCharges.start(it);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
#define MAX_BUGS 10
    struct VoodooVial {
        private timer tm;
        private unit bug[MAX_BUGS];
        private effect eff[MAX_BUGS];
        private unit u;
        private real x, y;
        private integer tick;
        
        private method destroy() {
            integer i = 0;
            ReleaseTimer(this.tm);
            while (i < MAX_BUGS) {
                DestroyEffect(this.eff[i]);
                this.eff[i] = null;
                KillUnit(this.bug[i]);
                this.bug[i] = null;
                i += 1;
            }
            this.u = null;
            this.tm = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer j, i;
            real angle, distance;
            if (ModuloInteger(this.tick, 10) == 1) {
                j = 0;
                while (j < MobList.n) {
                    if (GetDistance.unitCoord(MobList.units[j], this.x, this.y) < 250 && !IsUnitDead(MobList.units[j])) {
                        DamageTarget(this.u, MobList.units[j], 73.0, SpellData[SID_VOODOO_VIAL].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                        AddTimedEffect.atUnit(ART_PLAGUE, MobList.units[j], "origin", 0.5);
                    }
                    j += 1;
                }
            }
            i = 0;
            while (i < MAX_BUGS) {
                if (GetRandomInt(0, 99) < 20) {
                    angle = GetRandomReal(0.0, 6.283);
                    distance = GetRandomReal(1.0, 62500.0);
                    distance = SquareRoot(distance);
                    IssuePointOrderById(this.bug[i], OID_MOVE, this.x + Cos(angle) * distance, this.y + Sin(angle) * distance);
                }
                i += 1;
            }
            this.tick -= 1;
            if (this.tick < 1) {
                this.destroy();
            }
        }
        
        static method start(unit caster, real x, real y) {
            thistype this = thistype.allocate();
            integer i;
            integer bugid = bugs[GetRandomInt(0, 4)];
            real angle, distance;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = caster;
            this.x = x;
            this.y = y;
            this.tick = 50;
            i = 0;
            while (i < MAX_BUGS) {
                angle = GetRandomReal(0.0, 6.283);
                distance = GetRandomReal(1.0, 62500.0);
                distance = SquareRoot(distance);
                this.bug[i] = CreateUnit(GetOwningPlayer(caster), bugid, x + Cos(angle) * distance,  y + Sin(angle) * distance, angle * bj_RADTODEG);
                this.eff[i] = AddSpecialEffectTarget(ART_POISON, this.bug[i], "origin");
                i += 1;
            }
            TimerStart(this.tm, 0.1, true, function thistype.run);
        }
    }
#undef MAX_BUGS

    struct Parabola_sin {
        private real stepx, stepy;
        private integer tick;
        private unit mis;
        private real tx, ty;
        private effect eff;
        private timer tm;
        private real sinStep;
        private real height;
        private unit caster;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.mis = null;
            this.eff = null;
            this.tm = null;
            this.caster = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            SetUnitFlyHeight(this.mis, Sin(this.sinStep * this.tick) * this.height, 0.0);
            SetUnitX(this.mis, GetUnitX(this.mis) + this.stepx);
            SetUnitY(this.mis, GetUnitY(this.mis) + this.stepy);
            this.tick -= 1;
            if (this.tick < 1) {
                DestroyEffect(this.eff);
                KillUnit(this.mis);
                VoodooVial.start(this.caster, this.tx, this.ty);
                this.destroy();
            }
        }
    
        static method start(real ox, real oy, real tx, real ty, real height, real speed, string path, unit caster) {
            thistype this = thistype.allocate();
            real angle = GetAngle(ox, oy, tx, ty);
            real step = speed / 25.0;
            this.tx = tx;
            this.ty = ty;
            this.stepx = Cos(angle) * step;
            this.stepy = Sin(angle) * step;
            this.tick = Rounding(GetDistance.coords2d(ox, oy, tx, ty) / step);
            this.sinStep = 3.1415 / this.tick;
            this.mis = CreateUnit(Player(0), DUMMY_ID, ox, oy, angle * bj_RADTODEG);
            SetUnitFlyable(this.mis);
            this.eff = AddSpecialEffectTarget(path, this.mis, "origin");
            this.height = height;
            this.caster = caster;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }
    
    function onCast() {
        Parabola_sin.start(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), SpellEvent.TargetX, SpellEvent.TargetY, 400.0, 600.0, MISSILE, SpellEvent.CastingUnit);
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_VOODOO_VIAL, action);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterDamagedEvent(damaged);
        RegisterSpellEffectResponse(SID_VOODOO_VIAL, onCast);
        bugsn = 5;
        bugs[0] = 'e005';
        bugs[1] = 'e006';
        bugs[2] = 'e007';
        bugs[3] = 'e008';
        bugs[4] = 'e00A';
    }
#undef MISSILE
#undef BUFF_ID
}
//! endzinc
