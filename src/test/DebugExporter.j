//! zinc
library DebugExporter requires Integer {
    private string list[];
    private integer n;

    public function print(string str) {
        BJDebugMsg(str);
        list[n] = str;
        n += 1;
    }

    public function logcat(string str) {
        BJDebugMsg(str);
        list[n] = str;
        n += 1;
    }
    
    public function ExportDebugLog() {
        string contents = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><style type=\"text/css\">body {background:#000;} span {color:#0F0;} .inv {display:none;}</style></head><body><div class=\"inv\">";
        string filename = "D:\\WExport\\ZAM_Debug_Log_" + I2HEX(GetRandomInt(0, 0x7FFFFFFF)) + ".html";
        integer i = 0;
        PreloadGenStart();
        Preload(contents);
        while (i < n) {
            Preload("</div><br/><span>" + list[i] + "</span><div class=\"inv\">");
            i += 1;
        }
        Preload("</div><br/></body></html>");
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
