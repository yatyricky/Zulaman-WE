//! zinc
library EyeBeam requires DamageSystem {

    struct EyeBeamData {
        lightning l;
        vector origin, direction;
        vector normal;
        vector v1, v2;
        real z;
        
        method destroy() {
            DestroyLightning(this.l);
            this.l = null;
            this.origin.destroy();
            this.direction.destroy();
            this.v1.destroy();
            this.v2.destroy();
            this.deallocate();
        }
    }

    function response(CastingBar cd) {
        EyeBeamData data = EyeBeamData(cd.extraData);
        integer i;
        // visual effect beam
        if (cd.nodes < 425) {
            data.direction.rotate(data.normal, 0.014784);
            data.v1.copy(data.origin);
            data.v1.add(data.direction);
            MoveLightningEx(data.l, true, data.origin.x, data.origin.y, data.z, data.v1.x, data.v1.y, data.z);
            
            if (ModuloInteger(cd.nodes, 5) == 0) {
                for (0 <= i < PlayerUnits.n) {
                    data.v2.x = GetUnitX(PlayerUnits.units[i]);
                    data.v2.y = GetUnitY(PlayerUnits.units[i]);
                    if (DistancePointAndLineSegment(data.origin, data.v1, data.v2) < 120.0 && GodOfDeathPlatform.isUnitInPlatform(PlayerUnits.units[i]) == false) {
                        DamageTarget(cd.caster, PlayerUnits.units[i], GetWidgetLife(PlayerUnits.units[i]), SpellData.inst(SID_EYE_BEAM, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                    }
                }
            }
            
            if (cd.nodes == -1) {
                data.destroy();
            }
        }
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        EyeBeamData lbd = EyeBeamData.create();
        cb.extraData = lbd;
        lbd.z = GetLocZ(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit)) + 30.0;
        lbd.origin = vector.create(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0);
        lbd.direction = vector.create(0, 3072, 0);
        lbd.normal = vector.create(0, 0, 100);
        lbd.v1 = vector.sum(lbd.origin, lbd.direction);
        lbd.v2 = vector.create(0, 0, 0);
        lbd.l = AddLightningEx("SPLK", true, lbd.origin.x, lbd.origin.y, lbd.z, lbd.v1.x, lbd.v1.y, lbd.z);
        SetLightningColor(lbd.l, 1.0, 0.3, 1.0, 1.0);
        cb.channel(500);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_EYE_BEAM, onChannel);
    }

}
//! endzinc
