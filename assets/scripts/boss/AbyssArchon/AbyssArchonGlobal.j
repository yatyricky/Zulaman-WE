//! zinc
library AbyssArchonGlobal requires Handle2Integer {

    public struct AbyssArchonGlobal {
        private static boolean flip = true;
        static real poisonAOE = 400;
        static real abominationAOE = 300;
        static real wraithAOE = 250;
        static boolean summonedCrawler = false;
        static ListObject/*Point*/ poisons;
        static ListObject/*Ref<unit>*/ wraiths;

        static method reset() {
            thistype.summonedCrawler = false;
        }

        static method onInit() {
            thistype.poisons = ListObject.create();
        }

        static method wipeWraiths() {
            NodeObject iter = thistype.wraiths;
            while (iter != 0) {
                KillUnit(IntRefUnit(iter.data));
                iter = iter.next;
            }
        }

    }

}
//! endzinc
