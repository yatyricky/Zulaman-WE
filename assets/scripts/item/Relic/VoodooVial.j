//! zinc
library VoodooVial requires DamageSystem {
    HandleTable ht;
    integer bugs[];
    integer bugsn;
    
    struct AuroIncreaseCharges {
        private static HandleTable caht;
        private unit u;
        private timer tm;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            thistype.caht.flush(this.u);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer ii = 0;
            item ti;
            integer current;
            while (ii < 6) {
                ti = UnitItemInSlot(this.u, ii);
                if (ti != null && GetItemTypeId(ti) == ITID_VOODOO_VIALS) {
                    current = GetItemCharges(ti);
                    if (current < 5) {
                        SetItemCharges(ti, current + 1);
                    }
                }
                ii += 1;
            }
            ti = null;
        }
    
        static method start(unit u, boolean flag) {
            thistype this;
            if (!thistype.caht.exists(u)) {
                this = thistype.allocate();
                thistype.caht[u] = this;
                this.u = u;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
            } else {
                this = thistype.caht[u];
            }
            if (flag) {
                TimerStart(this.tm, 30.0, true, function thistype.run);
            } else {
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.caht = HandleTable.create();
        }
    }
    
constant integer MAX_BUGS = 10;
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
            integer ii = 0;
            item ti;
            real amt = 0;
            
            if (ModuloInteger(this.tick, 10) == 1) {
                while (ii < 6) {
                    ti = UnitItemInSlot(this.u, ii);
                    if (ti != null) {
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_USE_VOODOO, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX));
                    }
                    ii += 1;
                }
                ti = null;
                j = 0;
                while (j < MobList.n) {
                    if (GetDistance.unitCoord(MobList.units[j], this.x, this.y) < 250 && !IsUnitDead(MobList.units[j])) {
                        DamageTarget(this.u, MobList.units[j], amt, SpellData.inst(SID_VOODOO_VIALS, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
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
        Parabola_sin.start(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), SpellEvent.TargetX, SpellEvent.TargetY, 400.0, 600.0, ART_BOTTLE_MISSILE, SpellEvent.CastingUnit);
    }

    public function EquipedVoodooVials(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        if (ht[u] == 0) {
            AuroIncreaseCharges.start(u, true);
        }
        ht[u] = ht[u] + polar;
        if (ht[u] == 0) {
            AuroIncreaseCharges.start(u, false);
        }
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterSpellEffectResponse(SID_VOODOO_VIALS, onCast);
        bugsn = 5;
        bugs[0] = 'e005';
        bugs[1] = 'e006';
        bugs[2] = 'e007';
        bugs[3] = 'e008';
        bugs[4] = 'e00A';
    }


}
//! endzinc
