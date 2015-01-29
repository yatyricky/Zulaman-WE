//! zinc
library Console {
    private trigger consoleTrig;
    
    public type ConsoleAction extends function(string);

    public struct Console {
        private static Console instances[16];
        private player p;
        private integer listN;
        private ConsoleAction list[30];
        private string match[30];
    
        static method create(player p) -> thistype {
            thistype this = thistype.allocate();
            Console.instances[GetPlayerId(p)] = this;
            this.p = p;
            TriggerRegisterPlayerChatEvent(consoleTrig, p, "", false);
            this.listN = 0;
            return this;
        }
        
        static method operator[](player p) -> Console {
            return Console.instances[GetPlayerId(p)];
        }
        
        method evaluateAll(string str) {
            integer i = 0;
            while (i < this.listN) {
                if (this.match[i] == SubString(str, 0, StringLength(this.match[i]))) {
                    this.list[i].evaluate(str);
                }
                i += 1;
            }
        }
        
        method reset() {
            if (GetLocalPlayer() == this.p) {
                ClearTextMessages();
            }
            this.listN = 0;
        }
        
        method add(string str, ConsoleAction consoleAct) {
            if (this.listN >= 30) {
                BJDebugMsg("Console_Console_add: Index out of boundary.");
            } else {
                this.list[this.listN] = consoleAct;
                this.match[this.listN] = str;
                this.listN += 1;
            }
        }
    }
    
    private function action() {
        Console[GetTriggerPlayer()].evaluateAll(GetEventPlayerChatString());
    }
        
    private function onInit() {
        consoleTrig = CreateTrigger();
        TriggerAddAction(consoleTrig, function action);
        
        Console.create(Player(0));
    }
}
//! endzinc
