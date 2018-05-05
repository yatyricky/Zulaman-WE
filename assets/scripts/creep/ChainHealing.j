//! zinc
library ChainHealing requires SpellEvent, DamageSystem {
constant string  ART_CH_LIGHT  = "HWPB";
constant string  ART_TARGET  = "Abilities\\Spells\\Orc\\HealingWave\\HealingWaveTarget.mdl";
constant real JUMP_FACTOR = 1.5;
constant integer MAX_TARGETS = 3;
constant integer INIT_AMT = 1000;

    unit mobs[];
    integer num;

    function response(CastingBar cd) {
        unit prev = SpellEvent.CastingUnit;
        unit next = SpellEvent.TargetUnit;
        real amount = INIT_AMT;
        integer count = MAX_TARGETS;
        real dis = 9999, tr;
        unit new;
        
        // make copy
        integer i = 0;
        integer index;
        num = 0;
        while (i < MobList.n) {
            if (!IsUnit(MobList.units[i], SpellEvent.CastingUnit) && !IsUnit(MobList.units[i], SpellEvent.TargetUnit)) {
                mobs[num] = MobList.units[i];
                num += 1;
            }
            i += 1;
        }
        
        while (count > 0) {
            AddTimedLight.atUnits(ART_CH_LIGHT, prev, next, 0.5);
            AddTimedEffect.atUnit(ART_TARGET, next, "origin", 0.1);
            HealTarget(SpellEvent.CastingUnit, next, amount, SpellData.inst(SID_CHAIN_HEALING, SCOPE_PREFIX).name, 0.0);
            prev = next;
            
            new = null;
            i = 0;
            dis = 9999.;
            while (i < num) { 
                tr = GetDistance.units(next, mobs[i]);
                if (tr < dis) {
                    dis = tr;
                    new = mobs[i];
                    index = i;
                }
                i += 1;
            }
            if (new != null) {
                num -= 1;
                mobs[index] = mobs[num];
                next = new;
                amount *= JUMP_FACTOR;
                count -= 1;
            } else {
                count -= MAX_TARGETS;
            }            
        }
        
        next = null;
        prev = null;
        new = null;
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_CHAIN_HEALING, onChannel);
    }
    





}
//! endzinc
