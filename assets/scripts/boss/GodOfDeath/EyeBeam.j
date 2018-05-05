//! zinc
library EyeBeam {
constant real STEP = 0.3696;

    struct EyeBeamData {
        lightning l;
        vector origin, direction;
        vector normal;
        vector v1, v2;
        
        method destroy() {
            DestroyLightning(this.l);
            this.l = null;
            this.origin.destroy();
            this.direction.destroy();
            this.v1.destroy();
            this.deallocate();
        }
    }

    function response(CastingBar cd) {
        EyeBeamData data = EyeBeamData(cd.extraData);
        integer i;
        // visual effect beam
        if (cd.nodes < 425) {
            data.direction.rotate(data.normal, STEP);
            data.v1.copy(data.origin);
            data.v1.add(data.direction);
            MoveLightningEx(data.l, false, data.origin.x, data.origin.y, data.origin.z, data.v1.x, data.v1.y, data.v1.z);
            
            if (ModuloInteger(cd.nodes, 5) == 0) {
                for (0 <= i < PlayerUnits.n) {
                    data.v2.x = GetUnitX(PlayerUnits.units[i]);
                    data.v2.y = GetUnitY(PlayerUnits.units[i]);
                    if (DistancePointAndLineSegment(data.origin, data.v1, data.v2) < 100.0) {
                        DamageTarget(cd.caster, PlayerUnits.units[i], GetWidgetLife(PlayerUnits.units[i]) * 1.3, SpellData.inst(SID, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
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
        lbd.origin = vector.create(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0);
        lbd.direction = vector.create(0, 1200, 0);
        lbd.normal = vector.create(0, 0, 1);
        lbd.v1 = vector.sum(lbd.origin, lbd.direction);
        lbd.v2 = vector.create(0, 0, 0);
        lbd.l = AddLightningEx("SPLK", false, lbd.origin.x, lbd.origin.y, lbd.origin.z, lbd.v1.x, lbd.v1.y, lbd.v1.z);
        SetLightningColor(lbd.l, 1.0, 0.6, 0.6, 1.0);
        cb.channel(500);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID, onChannel);
    }

}
//! endzinc
