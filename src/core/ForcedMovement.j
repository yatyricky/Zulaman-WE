//! zinc
library ForcedMovement requires TimerUtils, ZAMCore {
    
    private struct ForcedMovement {
        private static HandleTable ht;
        private timer tm;
        private unit u;
        private real dx, dy, accr;
        private integer count, frames;

        private method destroy() {
            ReleaseTimer(this.tm);
            thistype.ht.flush(this.u);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real factor;
            if (IsUnitDead(this.u)) {
                this.destroy();
            } else {
                factor = (this.frames - this.count) / this.frames * this.accr;
                SetUnitPosition(this.u, GetUnitX(this.u) + this.dx + this.dx * factor, GetUnitY(this.u) + this.dy + this.dy * factor);
                this.count -= 1;
                if (this.count <= 0) {
                    this.destroy();
                }
            }
        }

        static method start(unit u, real dx, real dy, integer frames, real accr) {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                thistype.ht[u] = this;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                this.u = u;
            }
            this.dx = dx;
            this.dy = dy;
            this.accr = accr;
            this.count = frames;
            this.frames = frames;
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    public function ForceMoveUnitPolar(unit u, real dx, real dy, integer frames, real accerlaration) {
        ForcedMovement.start(u, dx, dy, frames, accerlaration);
    }

}
//! endzinc
