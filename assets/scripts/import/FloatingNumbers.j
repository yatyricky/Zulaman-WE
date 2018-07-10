//! zinc
library FloatingNumbers requires TimerUtils {
    constant real FONT_SIZE = 0.0264;
    constant real MEAN_CHAR_WIDTH = 5.5;
    constant real MAX_TEXT_SHIFT = 200.0;
    constant real DEFAULT_HEIGHT = 16.0;

    constant integer shrinkPoint = 5;
    constant integer fadePoint = 20;
    constant integer lifeSpan = 40;
    constant real speed = 6;

    public struct FloatingNumbers {
        texttag tt;
        real sizeReduce, maxSize;
        real dx, dy;
        real cx, cy;
        string text;
        integer c;
        timer tm;

        method destroy() {
            ReleaseTimer(this.tm);
            DestroyTextTag(this.tt);
            this.tt = null;
            this.tm = null;
            this.deallocate();
        }

        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real size;
            if (this.c < shrinkPoint) {
                size = this.maxSize - this.sizeReduce * (this.c + 1);
                SetTextTagText(this.tt, this.text, FONT_SIZE * size);
            }
            this.c += 1;
            if (this.c > lifeSpan) {
                this.destroy();
            }
        }

        static method create(string text, string color, real x, real y, real maxSize, boolean isTop) -> thistype {
            thistype this = thistype.allocate();
            real xoff = RMinBJ(StringLength(text) * MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT);
            real angle;
            this.tt = CreateTextTag();
            this.text = COLOR_CFF + color + text + COLOR_R;
            this.c = 0;
            this.maxSize = maxSize;
            this.sizeReduce = (maxSize - 1) / shrinkPoint;
            this.cx = x - xoff;
            this.cy = y;
            if (isTop == true) {
                angle = GetRandomReal(bj_PI * 0.25, bj_PI * 0.55);
                this.cy += 30;
            } else {
                angle = GetRandomReal(bj_PI * 1.25, bj_PI * 1.55);
                this.cy -= 30;
            }
            this.dx = Cos(angle) * speed;
            this.dy = Sin(angle) * speed;
            SetTextTagText(this.tt, this.text, FONT_SIZE * maxSize);
            SetTextTagPos(this.tt, this.cx, this.cy, DEFAULT_HEIGHT);
            SetTextTagVelocity(this.tt, this.dx * 0.01, this.dy * 0.01);
            SetTextTagVisibility(this.tt, true);
            SetTextTagFadepoint(this.tt, fadePoint * 0.04);
            SetTextTagLifespan(this.tt, lifeSpan * 0.04);
            SetTextTagPermanent(this.tt, false);
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.run);
            return this;
        }
    }

}
//! endzinc
