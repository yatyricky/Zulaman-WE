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
            while (iter != 0) {
                eff = IntRefEff(iter.data);
                BlzSetSpecialEffectX(eff, BlzGetLocalSpecialEffectX(eff) + this.step * Cos(bj_PI * 2.0 / this.list.count() * i));
                BlzSetSpecialEffectY(eff, BlzGetLocalSpecialEffectY(eff) + this.step * Sin(bj_PI * 2.0 / this.list.count() * i));
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
                BlzSetSpecialEffectYaw(eff, bj_PI * 2.0 / num * i);
                list.push(Eff2Int(eff));
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

    }

}
//! endzinc
