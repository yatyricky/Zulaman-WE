//! zinc
library Patrol requires NefUnion {    
#define RADIUS 200

    Patroller pats[];
    integer nump;
    
    private struct PatrolNode {
        real x, y;
        PatrolNode next;
        
        public static method create(real x, real y) -> thistype {
            thistype this = thistype.allocate();
            this.x = x;
            this.y = y;
            this.next = 0;
            return this;
        }
    }

    public struct Patroller {
        private static HandleTable ht;
        unit u;
        private PatrolNode head, tail;
        private PatrolNode mission;
        
        public method run() {
            if (GetDistance.unitCoord(this.u, this.mission.x, this.mission.y) < RADIUS) {
                this.mission = this.mission.next;
            }            
            IssuePointOrderById(this.u, OID_ATTACK, this.mission.x, this.mission.y);
        }

        static method operator[] (unit u) -> thistype {
            if (thistype.ht.exists(u)) {
                return thistype.ht[u];
            } else {
                return 0;
            }
        }
        
        public method add(real x, real y) -> thistype {
            PatrolNode pn = PatrolNode.create(x, y);
            this.tail.next = pn;
            this.tail = pn;
            pn.next = this.head;
            return this;
        }
        
        public static method create(unit u) -> thistype {
            thistype this = thistype.allocate();
            this.u = u;
            this.head = PatrolNode.create(GetUnitX(u), GetUnitY(u));
            this.tail = this.head;
            this.mission = this.head;
            thistype.ht[u] = this;
            pats[nump] = this;
            nump += 1;
            return this;
        }

        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function patrolRun() {
        integer i = 0;
        while (i < nump) {
            if (MobList.locate(pats[i].u) == -1) {
                pats[i].run();
            }
            i += 1;
        }
    }
    
    function onInit() {
        nump = 0;
        TimerStart(CreateTimer(), 1.0, true, function patrolRun);
    }
#undef RADIUS
}
//! endzinc
