//! zinc
library ChainLightning requires DamageSystem {

    public struct ChainLightning {
        private timer tm;
        private integer count;
        private unit caster, next;
        private real amount, factor;
        private string less, abilName;
        private HandleTable ht;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.next = null;
            this.less = null;
            this.ht.destroy();
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            unit tu;
            real distance = 9999.0;
            real td;
            unit nextt = null;
            GroupUnitsInArea(ENUM_GROUP, GetUnitX(this.next), GetUnitY(this.next), 450.0);
            tu = FirstOfGroup(ENUM_GROUP);
            while (tu != null) {
                GroupRemoveUnit(ENUM_GROUP, tu);
                if (!IsUnitDummy(tu) && !IsUnitUseless(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(this.caster)) && !this.ht.exists(tu)) {
                    td = GetDistance.units2d(this.next, tu);
                    if (td < distance) {
                        distance = td;
                        nextt = tu;
                    }
                }
                tu = FirstOfGroup(ENUM_GROUP);
            }
            if (nextt != null) {
                this.amount *= this.factor;
                DamageTarget(this.caster, nextt, this.amount, this.abilName, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
                AddTimedLight.atUnits(this.less, this.next, nextt, 0.7);
                AddTimedEffect.atUnit(ART_IMPACT, nextt, "origin", 0.2);
                this.ht[nextt] = 0x1A2B3C4D;
                this.next = nextt;
            } else {
                this.count = 0;
            }
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
            nextt = null;
            tu = null;
        }
        
        static method start(unit caster, unit target, string abilName, string maine, string less, real amt, integer num, real factor) {
            thistype this = thistype.allocate();
            UnitProp up = UnitProp.inst(caster, SCOPE_PREFIX);
            this.caster = caster;
            this.abilName = abilName;
            this.amount = amt + (up.AttackPower() + up.SpellPower()) * 0.125;
            DamageTarget(caster, target, this.amount, abilName, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
            AddTimedLight.atUnits(maine, caster, target, 0.7);
            AddTimedEffect.atUnit(ART_IMPACT, target, "origin", 0.2);
            this.factor = factor;
            this.less = less;
            this.count = num;
            this.next = target;
            this.ht = HandleTable.create();
            this.ht[target] = 0x1A2B3C4D;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.35, true, function thistype.run);
        }
    }

}
//! endzinc
