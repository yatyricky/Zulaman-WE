//! zinc
library MarkOfAgony {
/*
target takes same amount of damage maid of agony takes
magical negative effect
*/

	struct MarkOfAgony {
		private static HandleTable ht;
		private unit caster;
		private unit targets[32];
		private integer n;

		static method operator[](unit u) -> thistype {
			if (thistype.ht.exists(u)) {
				this = thistype.ht[u];
			} else {
				this = thistype.allocate();
				thistype.ht[u] = this;
				this.caster = u;
				this.n = 0;
			}
			return this;
		}

		static method start(unit caster, unit target) -> thistype {
			thistype this = thistype.allocate();
			this.caster
			return this;
		}

		private static method onInit() {
			thistype.ht = HandleTable.create();
		}
	}

    function onEffect(Buff buf) {
    	MarkOfAgony[buf.bd.caster].add(buf.bd.target);
    }

    function onRemove(Buff buf) {
    	MarkOfAgony[buf.bd.caster].remove(buf.bd.target);
    }
	
	function onCast() {
		Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID);
        buf.bd.tick = -1;
        buf.bd.interval = 12;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART_PLAGUE, SpellEvent.TargetUnit, "origin", 0.2);
	}

    function onInit() {
        BuffType.register(BID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID, onCast);
    }
}
//! endzinc
 