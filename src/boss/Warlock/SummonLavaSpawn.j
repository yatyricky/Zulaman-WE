//! zinc
library SummonLavaSpawn requires SpellEvent, ZAMCore, WarlockGlobal {
#define PATH "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"
    unit lastFireRune;
    integer count;

    function response(CastingBar cd) {
        integer i = 0;
		if (cd.nodes > 0) {
			AddTimedEffect.atCoord(PATH, GetUnitX(lastFireRune), GetUnitY(lastFireRune), 0.5);
			KillUnit(lastFireRune);
			while (i < count) {
				CreateUnit(Player(MOB_PID), UTID_LAVA_SPAWN, GetUnitX(lastFireRune), GetUnitY(lastFireRune), GetRandomReal(0, 360));
				i += 1;
			}
			NextFireRune();
			count += 1;
			// print("take effect " + I2S(cd.nodes));
			if (cd.nodes > 1) {
				lastFireRune = GetFireRune();
				if (lastFireRune != null) {
					AddTimedLight.atUnits("DRAL", cd.caster, lastFireRune, 2.0).setColour(1.0, 0.33, 0.0, 1.0);
				} else {
					IssueImmediateOrderById(cd.caster, OID_STOP);
				}
			}
		}
    }

    function onChannel() {
        lastFireRune = GetFireRune();
        if (lastFireRune != null) {
            CastingBar.create(response).channel(5);
            count = 1;
            AddTimedLight.atUnits("DRAL", SpellEvent.CastingUnit, lastFireRune, 2.0).setColour(1.0, 0.33, 0.0, 1.0);
        } else {
            IssueImmediateOrderById(SpellEvent.CastingUnit, OID_STOP);
        }
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDSUMMONLAVASPAWN, onChannel);
    }
#undef PATH
}
//! endzinc
