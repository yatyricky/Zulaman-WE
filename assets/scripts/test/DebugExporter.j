//! zinc
library DebugExporter requires Integer, Clock {
    private string list[];
    private integer n;

    public function logi(string str) {
        string sb = "[" + R2S(GetGameTime()) + "]" + str;
        BJDebugMsg(sb);
        list[n] = sb;
        n += 1;
    }

    public function loge(string str) {
        string sb = "[" + R2S(GetGameTime()) + "]" + "|cffff0000ERROR|r: " + str;
        BJDebugMsg(sb);
        list[n] = sb;
        n += 1;
    }

    public function print(string str) {
        logi(str);
    }
    
    public function ExportDebugLog() {
        string contents = "";
        string filename = "debugLog.pld";
        integer i = 0;
        PreloadGenStart();
        while (i < n) {
            Preload(list[i]);
            i += 1;
        }
        PreloadGenEnd(filename);
        PreloadGenClear();
        n = 0;
        filename = null;
        contents = null;
    }
    
    private function onInit() {
        n = 0;
    }
}
//! endzinc
