//! zinc
library Clock {
//==============================================================================
//  时钟：
//      获得当前游戏已过时间。
//==============================================================================
//  real:   GetGameTime()
//      以秒为单位获得时间。
//  Time:   GetGameTimeDetail()
//      获得一个Time结构类型的当前时间。
//==============================================================================
//  Time
//      integer:    hour    //小时
//      integer:    minute  //分钟
//      real:       second  //秒
//      nothing:    destroy()
//          销毁该时间结构
//      string:     toString()
//          将该时间以 H:M:S 的格式转化为字符串
//==============================================================================
//  [Warft]Nef.
//==============================================================================
    constant real INTERVAL = 60.0;
    real time;    
    timer clock;
    
    public struct Time {
        integer hour, minute;
        real second;
        
        method destroy() {
            this.deallocate();
        }
        
        method toString() -> string {
            return I2S(this.hour) + ":" + I2S(this.minute) + ":" + R2S(this.second);
        }
    }
    
    public function GetGameTime() -> real {
        return time + TimerGetElapsed(clock);
    }
    
    public function GetGameTimeDetail() -> Time {
        real ct = GetGameTime();
        Time t = Time.create();
        integer intct = R2I(ct);
        ct = ct - intct;
        t.hour = intct / 3600;
        intct -= t.hour * 3600;
        t.minute = intct / 60;
        intct -= t.minute * 60;
        t.second = intct + ct;
        return t;
    }
    
    function onInit() {
        clock = CreateTimer();
        time = 0.0;
        TimerStart(clock, INTERVAL, true, function() {
            time += INTERVAL;
        });
    }
}
//! endzinc
