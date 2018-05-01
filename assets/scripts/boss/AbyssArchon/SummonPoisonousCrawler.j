//! zinc
library PoisonousCrawler requires DamageSystem, BuffSystem {
constant string  ART  = "units\\undead\\PlagueCloud\\PlagueCloud.mdl";

    HandleTable ownerHT;

    struct LowEfficiencyWrapper {
        private static HandleTable ht;
        unit u;

        static method new(unit u) -> thistype {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                this.u = u;
                thistype.ht[u] = this;
            }
            return this;
        }

        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_SUMMON_POISONOUS_CRAWLER].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    struct PoisonousCrawlerPoison {
        private unit caster;
        private Point p;
        private timer tm;
        private integer ctr;

        private method destroy() {
            ReleaseTimer(this.tm);
            this.p.destroy();
            this.tm = null;
            this.caster = null;
            this.deallocate();
        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            Buff buf;
            for (0 <= i < PlayerUnits.n) {
                // if any player unit is in range, debuff them
                if (GetDistance.unitCoord(PlayerUnits.units[i], this.p.x, this.p.y) < AbyssArchonGlobal.poisonAOE) {
                    if (GetUnitAbilityLevel(PlayerUnits.units[i], BID_SUMMON_POISONOUS_CRAWLER) == 0) {
                        buf = Buff.cast(this.caster, PlayerUnits.units[i], BID_SUMMON_POISONOUS_CRAWLER);
                        buf.bd.interval = 2.0;
                        buf.bd.tick = 15;
                        buf.bd.r0 = 200.0;
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
                    }
                }
            }

            this.ctr -= 1;
            if (this.ctr <= 0) {
                this.destroy();
            }
        }

        static method start(unit caster, Point p) {
            thistype this = thistype.allocate();
            this.caster = caster;
            this.p = p;
            this.ctr = 100;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.1, true, function thistype.run);

            AddTimedEffect.atCoord(ART, p.x, p.y, 10.0);
            AddTimedEffect.atCoord(ART, p.x, p.y + 256, 10.0);
            AddTimedEffect.atCoord(ART, p.x, p.y - 256, 10.0);
            AddTimedEffect.atCoord(ART, p.x + 256, p.y, 10.0);
            AddTimedEffect.atCoord(ART, p.x - 256, p.y, 10.0);
            AddTimedEffect.atCoord(ART, p.x + 180, p.y - 180, 10.0);
            AddTimedEffect.atCoord(ART, p.x + 180, p.y + 180, 10.0);
            AddTimedEffect.atCoord(ART, p.x - 180, p.y - 180, 10.0);
            AddTimedEffect.atCoord(ART, p.x - 180, p.y + 180, 10.0);

            // DrawCircle(p.x, p.y, AbyssArchonGlobal.poisonAOE, 24, "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes2.mdl", 10);
        }
    }

    function poisonousCrawlerDeath(unit u) {
        if (GetUnitTypeId(u) == UTID_POISONOUS_CRAWLER) {
            PoisonousCrawlerPoison.start(LowEfficiencyWrapper(ownerHT[u]).u, Point.new(GetUnitX(u), GetUnitY(u)));
            ownerHT.flush(u);
        }
        if (GetUnitTypeId(u) == UTID_NOXIOUS_SPIDER) {
            PoisonousCrawlerPoison.start(u, Point.new(GetUnitX(u), GetUnitY(u)));
            
        }
    }

    function onCast() {
        unit crawler;
        Point p = AbyssArchonGlobal.getSummonPoint();
        crawler = CreateUnit(Player(MOB_PID), UTID_POISONOUS_CRAWLER, p.x, p.y, GetRandomReal(0, 359));
        ownerHT[crawler] = LowEfficiencyWrapper.new(SpellEvent.CastingUnit);
        crawler = null;
        p.destroy();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_POISONOUS_CRAWLER, onCast);
        BuffType.register(BID_SUMMON_POISONOUS_CRAWLER, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(poisonousCrawlerDeath);
        ownerHT = HandleTable.create();
    }

}
//! endzinc
