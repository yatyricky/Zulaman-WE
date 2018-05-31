//! zinc
library Assertion requires DebugExporter {

    public function AssertInt(integer a, integer b) {
        if (a == b) {
            logi("|cff00ff00PASS|r: Expected " + I2S(b));
        } else {
            logi("|cffff0000FAIL|r: Expected " + I2S(b) + " Result " + I2S(a));
        }
    }

}
//! endzinc
