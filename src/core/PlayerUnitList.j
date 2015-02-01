//! zinc
library PlayerUnitList requires NefUnion, GroupUtils, ZAMCore {
    //public group heroGroup;
    
    //private function onInit() {
    //    heroGroup = NewGroup();
    //    GroupRefresh(heroGroup);
    //}
    
    public function SortRuleManaPercentAsc(unit u1, unit u2) -> boolean {
        return GetUnitManaPercent(u1) > GetUnitManaPercent(u2);
    }

    public struct PlayerUnits {
        static integer n;
        static unit units[];
        static unit sorted[];
        static group g;
        
        static method locate(unit u) -> integer {
            integer i = 0;
            while (i < thistype.n) {
                if (thistype.units[i] == u) {
                    return i;
                } else {
                    i += 1;
                }
            }
            return -1;
        }
        
        /*static method getRandom() -> unit {
            if (thistype.n == 0) {
                return null;
            } else {
                return thistype.units[GetRandomInt(0, thistype.n - 1)];
            }
        }*/
        
        static method getRandomHero() -> unit {
            integer considered = 0;
            integer i = 0;
            unit ret = null;
            if (thistype.n == 0) {
                return null;
            } else {
                while (i < thistype.n) {
                    if (IsUnitType(thistype.units[i], UNIT_TYPE_HERO)) {
                        considered += 1;
                        if (GetRandomInt(1, considered) == 1) {
                            ret = thistype.units[i];
                        }
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method getRandomInRange(unit base, real dis) -> unit {
            integer considered = 0;
            integer i = 0;
            unit ret = null;
            if (thistype.n == 0) {
                return null;
            } else {
                while (i < thistype.n) {
                    if (GetDistance.units2d(base, thistype.units[i]) <= dis && !IsUnitUseless(thistype.units[i])) {
                        //BJDebugMsg(GetUnitNameEx(thistype.units[i]) + " considered");
                        considered += 1;
                        if (GetRandomInt(1, considered) == 1) {
                            ret = thistype.units[i];
                        }
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method sortByRule(UnitListSortRule rule) {
            integer i, j, mi;
            unit tmp;
            // make copy
            i = 0;
            while (i < thistype.n) {
                thistype.sorted[i] = thistype.units[i];
                i += 1;
            }
            // sort
            i = 0;
            while (i < thistype.n - 1) {
                mi = i;
                j = i + 1;
                while (j < thistype.n) {
                    if (rule.evaluate(thistype.sorted[i], thistype.sorted[j])  && !IsUnitUseless(thistype.sorted[j])) {
                        mi = j;
                    }
                    j += 1;
                }
                tmp = thistype.sorted[i];
                thistype.sorted[i] = thistype.sorted[mi];
                //print("PlayerUnitList[" + I2S(i) + "] = " + GetUnitNameEx(thistype.sorted[mi]));
                thistype.sorted[mi] = tmp;
                i += 1;
            }
            tmp = null;
        }
        
        static method getLowestHPAbove(real lowcap) -> unit {
            unit ret;
            real dis, td;
            integer i;
            if (thistype.n == 0) {
                return null;
            } else {
                ret = null;
                dis = 999999;
                i = 0;
                while (i < thistype.n) {
                    td = GetWidgetLife(thistype.units[i]);
                    if (td < dis && td > lowcap && !IsUnitUseless(thistype.units[i])) {
                        dis = td;
                        ret = thistype.units[i];
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method getLowestHPWithoutBuff(integer abil) -> unit {
            unit ret;
            real dis, td;
            integer i;
            if (thistype.n == 0) {
                return null;
            } else {
                ret = null;
                dis = 999999;
                i = 0;
                while (i < thistype.n) {
                    td = GetWidgetLife(thistype.units[i]);
                    if (td < dis && (GetUnitAbilityLevel(thistype.units[i], abil) == 0) && !IsUnitUseless(thistype.units[i])) {
                        dis = td;
                        ret = thistype.units[i];
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method getRandomExclude(unit ex) -> unit {
            integer considered = 0;
            integer i = 0;
            unit ret = null;
            if (thistype.n == 0) {
                return null;
            } else {
                while (i < thistype.n) {
                    if (!IsUnit(ex, thistype.units[i]) && !IsUnitUseless(thistype.units[i])) {
                        considered += 1;
                        if (GetRandomInt(1, considered) == 1) {
                            ret = thistype.units[i];
                        }
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method getFarest(unit from) -> unit {
            unit ret;
            real dis, td;
            integer i;
            if (thistype.n == 0) {
                return null;
            } else {
                ret = thistype.units[0];
                dis = GetDistance.units2d(from, thistype.units[0]);
                i = 1;
                while (i < thistype.n) {
                    td = GetDistance.units2d(from, thistype.units[i]);
                    if (td > dis && !IsUnitUseless(thistype.units[i])) {
                        dis = td;
                        ret = thistype.units[i];
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method getNearest(unit from) -> unit {
            unit ret;
            real dis, td;
            integer i;
            if (thistype.n == 0) {
                return null;
            } else {
                ret = null;
                dis = 9999.0;
                i = 0;
                while (i < thistype.n) {
                    td = GetDistance.units2d(from, thistype.units[i]);
                    if (td < dis && !IsUnit(from, thistype.units[i]) && !IsUnitUseless(thistype.units[i])) {
                        dis = td;
                        ret = thistype.units[i];
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method getNearestAngular(unit from, unit centre) -> unit {
            unit ret;
            real dis, td;
            integer i;
            if (thistype.n == 0) {
                return null;
            } else {
                ret = null;
                dis = 9999.0;
                i = 0;
                while (i < thistype.n) {
                    td = GetDistance.units2dAngular(from, thistype.units[i], centre);
                    if (td < dis && !IsUnit(from, thistype.units[i]) && !IsUnitUseless(thistype.units[i])) {
                        dis = td;
                        ret = thistype.units[i];
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        static method remove(integer i) {
            if (i != -1) {
                thistype.n -= 1;
                thistype.units[i] = thistype.units[thistype.n];
            } else {
                BJDebugMsg(SCOPE_PREFIX+">|cffff0000Error|r: about to delete element with index -1");
            }
        }
        
        static method delete(unit u) {
            thistype.remove(thistype.locate(u));
        }
        
        static method add(unit u) {
            thistype.units[thistype.n] = u;
            thistype.n += 1;
        }
        
        private static method onInit() {
            thistype.n = 0;
            thistype.g = NewGroup();
        }
    }
}
//! endzinc
