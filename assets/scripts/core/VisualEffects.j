//! zinc
library VisualEffects requires List {

    public struct VisualEffects {
        ListObject list;
        timer tm;
        real step;
        integer c;

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

        static method pierce() {

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

        static method circle(string model, real x, real y, real r, integer num, integer interval) {
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

    }

}
//! endzinc
