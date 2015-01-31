//! zinc
library RandomPrefixed requires ItemAttributes {
    //HandleTable ht;
    
    integer str = 0;
    integer ias = 0;
    integer agi = 0;
    integer int = 0;
    integer lif = 0;
    integer ap = 0;
    integer def = 0;
    integer man = 0;
    integer cri = 0;
    integer sh = 0;
    integer mr = 0;
    integer sp = 0;
    integer dge = 0;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        integer itid = GetItemTypeId(it);
        integer itype = itid / 0x100 * 0x100;
        integer prefix = itid - itype;
        //BJDebugMsg("itype = " + ID2S(itype));
        //BJDebugMsg("prefix = " + ID2S(prefix));
    
        str = 0;
        ias = 0;
        agi = 0;
        int = 0;
        lif = 0;
        ap = 0;
        def = 0;
        man = 0;
        cri = 0;
        sh = 0;
        mr = 0;
        sp = 0;
        dge = 0;
    
        itype += 0x30;
        if (itype == 'Igz0') {
            //BJDebugMsg("XX之攻击之爪");
            ap += 5;
        } else if (itype == 'Ijs0') {
            //BJDebugMsg("XX之加速手套");
            ias += 5;
        } else if (itype == 'Ics0') {
            //BJDebugMsg("XX之刺杀剑");
            cri += 3;
        } else if (itype == 'Ixp0') {
            //BJDebugMsg("XX之生命护符");
            lif += 80;
        } else if (itype == 'Ish0') {
            //BJDebugMsg("XX之守护指环");
            def += 2;
        } else if (itype == 'Isb0') {
            //BJDebugMsg("XX之闪避护符");
            dge += 1;
        } else if (itype == 'Inl0') {
            //BJDebugMsg("XX之能量");
            man += 100;
        } else if (itype == 'Imz0') {
            //BJDebugMsg("XX之艺人");
            mr += 4;
        } else if (itype == 'Iwz0') {
            //BJDebugMsg("XX之巫杖");
            sp += 10;
        } else if (itype == 'Igh0') {
            //BJDebugMsg("XX之圆环");
            str += 3; agi += 3; int += 3;
        }
        if (prefix == 0x31) {
            str += 5; agi += 5;
        } else if (prefix == 0x32) {
            str += 5; int += 5;
        } else if (prefix == 0x33) {
            agi += 5; int += 5;
        } else if (prefix == 0x34) {
            str += 8;
        } else if (prefix == 0x35) {
            agi += 8;
        } else if (prefix == 0x36) {
            int += 8;
        } else if (prefix == 0x37) {
            str += 5; ap += 8;
        } else if (prefix == 0x38) {
            str += 5; cri += 1;
        } else if (prefix == 0x39) {
            agi += 5; cri += 1;
        } else if (prefix == 0x61) {
            agi += 5; ap += 8;
        } else if (prefix == 0x62) {
            int += 5; sh += 2;
        } else if (prefix == 0x63) {
            int += 5; mr += 3;
        } else if (prefix == 0x64) {
            lif += 75; dge += 1;       
        }
        if (str > 0) {
            up.ModStr(str * fac);
        }
        if (agi > 0) {
            up.ModAgi(agi * fac);
        }
        if (int > 0) {
            up.ModInt(int * fac);
        }
        if (ias > 0) {
            up.ModAttackSpeed(ias * fac);
        }
        if (def > 0) {
            up.ModArmor(def * fac);
        }
        if (lif > 0) {
            up.ModLife(lif * fac);
        }
        if (man > 0) {
            up.ModMana(man * fac);
        }
        if (ap > 0) {
            up.ModAP(ap * fac);
        }
        if (cri > 0) {
            up.attackCrit += cri * 0.01 * fac;
        }
        if (sh > 0) {
            up.spellHaste += sh * 0.01 * fac;
        }
        if (mr > 0) {
            up.manaRegen += mr * fac;
        }
        if (sp > 0) {
            up.spellPower += sp * fac;
        }
        if (dge > 0) {
            up.dodge += dge * 0.01 * fac;
        }
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        integer i0 = 'Igz0';
        integer i1 = 'Ijs0';
        integer i2 = 'Ics0';
        integer i3 = 'Ixp0';
        integer i4 = 'Ish0';
        integer i5 = 'Isb0';
        integer i6 = 'Inl0';
        integer i7 = 'Imz0';
        integer i8 = 'Iwz0';
        integer i9 = 'Igh0';
        integer j = 0;
        while (j < 10) {
            RegisterItemPropMod(i0 + j, action);
            RegisterItemPropMod(i1 + j, action);
            RegisterItemPropMod(i2 + j, action);
            RegisterItemPropMod(i3 + j, action);
            RegisterItemPropMod(i4 + j, action);
            RegisterItemPropMod(i5 + j, action);
            RegisterItemPropMod(i6 + j, action);
            RegisterItemPropMod(i7 + j, action);
            RegisterItemPropMod(i8 + j, action);
            RegisterItemPropMod(i9 + j, action);
            j += 1;
        }
        i0 = 'Igza';
        i1 = 'Ijsa';
        i2 = 'Icsa';
        i3 = 'Ixpa';
        i4 = 'Isha';
        i5 = 'Isba';
        i6 = 'Inla';
        i7 = 'Imza';
        i8 = 'Iwza';
        i9 = 'Igha';
        j = 0;
        while (j < 4) {
            RegisterItemPropMod(i0 + j, action);
            RegisterItemPropMod(i1 + j, action);
            RegisterItemPropMod(i2 + j, action);
            RegisterItemPropMod(i3 + j, action);
            RegisterItemPropMod(i4 + j, action);
            RegisterItemPropMod(i5 + j, action);
            RegisterItemPropMod(i6 + j, action);
            RegisterItemPropMod(i7 + j, action);
            RegisterItemPropMod(i8 + j, action);
            RegisterItemPropMod(i9 + j, action);
            j += 1;
        }
    }
}
//! endzinc
