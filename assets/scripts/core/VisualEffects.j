//! zinc
library VisualEffects requires List, NefUnion {

    public struct VisualEffects {
        ListObject list;
        timer tm;
        real step, dx, dy, r;
        integer c;
        effect eff;
        string model;

        method destroy() {
            NodeObject iter = this.list.head;
            while (iter != 0) {
                DestroyEffect(Int2Eff(iter.data));
                iter = iter.next;
            }
            this.list.destroy();
            ReleaseTimer(this.tm);
            this.tm = null;
            this.deallocate();
        }

        static method destroySimple() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.destroy();
        }

        static method orbit() {

        }

        static method pierce(string model, real x, real y, real angle, real distance, real speed, real scale) {
            thistype this = thistype.allocate();
            this.dx = speed * 0.04 * Cos(angle);
            this.dy = speed * 0.04 * Sin(angle);
            this.c = R2I(distance / speed * 25.0);
            this.eff = AddSpecialEffect(model, x, y);
            BlzSetSpecialEffectScale(this.eff, scale);
            BlzSetSpecialEffectRoll(this.eff, angle);
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                real cx = BlzGetLocalSpecialEffectX(this.eff);
                real cy = BlzGetLocalSpecialEffectY(this.eff);
                BlzSetSpecialEffectPosition(this.eff, cx + this.dx, cy + this.dy, GetLocZ(cx + this.dx, cy + this.dy) + 30.0);
                this.c -= 1;
                if (this.c <= 0) {
                    DestroyEffect(this.eff);
                    ReleaseTimer(this.tm);
                    this.eff = null;
                    this.tm = null;
                    this.deallocate();
                }
            });
        }

        static method nova3d(string model, real x, real y, real z, real r, real speed, integer num) {

        }

        static method runNova() {
            thistype this = GetTimerData(GetExpiredTimer());
            NodeObject iter = this.list.head;
            effect eff;
            integer i = 0;
            real tx, ty;
            while (iter != 0) {
                eff = IntRefEff(iter.data);
                tx = BlzGetLocalSpecialEffectX(eff) + this.step * Cos(bj_PI * 2.0 / this.list.count() * i);
                ty = BlzGetLocalSpecialEffectY(eff) + this.step * Sin(bj_PI * 2.0 / this.list.count() * i);
                BlzSetSpecialEffectPosition(eff, tx, ty, GetLocZ(tx, ty) + 24.0);
                iter = iter.next;
                i += 1;
            }
            this.c -= 1;
            if (this.c <= 0) {
                this.destroy();
            }
            eff = null;
        }

        static method nova(string model, real x, real y, real r, real speed, integer num) -> thistype {
            thistype this = thistype.allocate();
            integer i = 0;
            effect eff;
            this.list = ListObject.create();
            while (i < num) {
                eff = AddSpecialEffect(model, x, y);
                BlzSetSpecialEffectRoll(eff, bj_PI * 2.0 / num * i);
                this.list.push(Eff2Int(eff));
                i += 1;
            }
            this.tm = NewTimer();
            this.step = speed * 0.04;
            this.c = Rounding(r / this.step);
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.runNova);
            eff = null;
            return this;
        }

        static method circle(string model, real x, real y, real r, integer num, real interval) {
            thistype this = thistype.allocate();
            integer i = 0;
            real rad = bj_PI * 2.0 / num;
            effect eff;
            this.tm = NewTimer();
            this.list = ListObject.create();
            while (i < num) {
                eff = AddSpecialEffect(model, x + Cos(rad * i) * r, y + Sin(rad * i) * r);
                BlzSetSpecialEffectRoll(eff, rad * i);
                this.list.push(Eff2Int(eff));
                i += 1;
            }
            SetTimerData(this.tm, this);
            TimerStart(this.tm, interval, false, function thistype.destroySimple);
        }

        static method drawCircleCallback(RepeatTask rt) {
            real x = rt.r0 + Cos(rt.r2 * rt.current) * rt.r3;
            real y = rt.r1 + Sin(rt.r2 * rt.current) * rt.r3;
            AddTimedEffect.atCoord(rt.s0, x, y, rt.r4).setRoll(rt.r2 * rt.current);
        }

        static method drawCircle(string model, real x, real y, real r, integer num, real interval, real life) {
            RepeatTask rt = RepeatTask.create(thistype.drawCircleCallback, interval, num);
            rt.r0 = x;
            rt.r1 = y;
            rt.r2 = bj_PI * 2.0 / num;
            rt.r3 = r;
            rt.r4 = life;
            rt.s0 = model;
        }

        static method line(string model, real x1, real y1, real x2, real y2, real step, real et) {
            thistype this = thistype.allocate();
            integer i;
            real dx, dy;
            real num = Rounding(GetDistance.coords2d(x1, y1, x2, y2) / step + 1);
            if (num < 2) {num = 2;}
            dx = (x2 - x1) / (num - 1);
            dy = (y2 - y1) / (num - 1);
            this.list = ListObject.create();
            i = 0;
            while (i < num) {
                this.list.push(Eff2Int(AddSpecialEffect(model, x1 + i * dx, y1 + i * dy)));
                i += 1;
            }
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, et, false, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                NodeObject iter = this.list.head;
                while (iter != 0) {
                    DestroyEffect(Int2Eff(iter.data));
                    iter = iter.next;
                }
                this.list.destroy();
                ReleaseTimer(this.tm);
                this.tm = null;
                this.deallocate();
            });
        }

        static method spamEffectsInTriangle(string model, real ox, real oy, real ax, real ay, real bx, real by, integer num, real life) {
            integer i = 0;
            real oax = ax - ox;
            real oay = ay - oy;
            real obx = bx - ox;
            real oby = by - oy;
            real oar, obr;
            real tx, ty;
            while (i < num) {
                oar = GetRandomReal(0.0, 1.0);
                obr = GetRandomReal(0.0, 1.0);
                if (oar + obr > 1) {
                    oar = 1 - oar;
                    obr = 1 - obr;
                }
                tx = oax * oar + obx * obr + ox;
                ty = oay * oar + oby * obr + oy;
                AddTimedEffect.atCoord(model, tx, ty, life);
                i += 1;
            }
        }

    }

}
//! endzinc
