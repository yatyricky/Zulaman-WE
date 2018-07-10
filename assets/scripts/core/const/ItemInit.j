//! zinc
library ItemInit requires ItemAttributes {

    function InitItems(DelayTask dt) {
        CreateItemEx(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 2936, -9463, 0);
        CreateItemEx(ITID_TIDAL_LOOP, -569, -8628, 0);
        CreateItemEx(ITID_VISKAG, 5591, -2456, 0);
        CreateItemEx(ITID_DETERMINATION_OF_VENGEANCE, 8185, 2931, 0);
        CreateItemEx(ITID_STRATHOLME_TRAGEDY, 10239, 8446, 0);
        CreateItemEx(ITID_PATRICIDE, -571, 11905, 0);
        CreateItemEx(ITID_FROSTMOURNE, -6389, 368, 0);
        CreateItemEx(ITID_ENIGMA, -4215, 3903, 0);
        CreateItemEx(ITID_DYING_BREATH, -130, 1150, 0);
    }

    function onInit() {
        DelayTask.create(InitItems, 1.0);
    }

}
//! endzinc
