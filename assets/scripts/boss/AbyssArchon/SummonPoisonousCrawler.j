//! zinc
library PoisonousCrawler requires DamageSystem, BuffSystem, AggroSystem {

    function onEffect(Buff buf) {
        DummyDamageTarget(buf.bd.target, buf.bd.r0, SpellData.inst(SID_SUMMON_POISONOUS_CRAWLER, SCOPE_PREFIX).name);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    struct PoisonousCrawlerPoison {
        private Point p;
        private timer tm;
        private integer ctr;

        private method destroy() {
            ReleaseTimer(this.tm);
            AbyssArchonGlobal.poisons.remove(this.p);
            this.p.destroy();
            this.tm = null;
            this.deallocate();
        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            Buff buf;
            for (0 <= i < PlayerUnits.n) {
                // if any player unit is in range, debuff them
                if (GetDistance.unitCoord(PlayerUnits.units[i], this.p.x, this.p.y) < AbyssArchonGlobal.poisonAOE) {
                    buf = Buff.cast(PlayerUnits.units[i], PlayerUnits.units[i], BID_SUMMON_POISONOUS_CRAWLER);
                    buf.bd.interval = 2.0;
                    buf.bd.tick = 25;
                    buf.bd.r0 = 200.0;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }

            this.ctr -= 1;
            if (this.ctr <= 0) {
                this.destroy();
            }
        }

        static method start(Point p) {
            thistype this = thistype.allocate();
            this.p = p;
            this.ctr = 100;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.1, true, function thistype.run);
            AbyssArchonGlobal.poisons.push(p);

            AddTimedEffect.atCoord(ART_PLAGUE, p.x, p.y, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x, p.y + 256, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x, p.y - 256, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x + 256, p.y, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x - 256, p.y, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x + 180, p.y - 180, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x + 180, p.y + 180, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x - 180, p.y - 180, 10.0);
            AddTimedEffect.atCoord(ART_PLAGUE, p.x - 180, p.y + 180, 10.0);

            // DrawCircle(p.x, p.y, AbyssArchonGlobal.poisonAOE, 24, "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes2.mdl", 10);
        }
    }

    function poisonousCrawlerDeath(unit u) {
        if (GetUnitTypeId(u) == UTID_POISONOUS_CRAWLER || GetUnitTypeId(u) == UTID_NOXIOUS_SPIDER) {
            PoisonousCrawlerPoison.start(Point.new(GetUnitX(u), GetUnitY(u)));
        }
    }

    function doSummonSpiders(DelayTask dt) {
        unit u;
        if (IsInCombat()) {
            u = CreateUnit(Player(MOB_PID), UTID_POISONOUS_CRAWLER, 9806, 8803, 90);
            AddTimedEffect.atUnit(ART_DarkSummonTarget, u, "origin", 0.2);
            u = null;
        }
        SetDoodadAnimation(9809, 8481, 200, 'D02X', false, "Stand", false);
    }

    function onCast() {
        DelayTask dt = DelayTask.create(doSummonSpiders, 5.0);
        SetDoodadAnimation(9809, 8481, 200, 'D02X', false, "Stand Work", false);
        AbyssArchonGlobal.summonedCrawler = true;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_POISONOUS_CRAWLER, onCast);
        BuffType.register(BID_SUMMON_POISONOUS_CRAWLER, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(poisonousCrawlerDeath);
    }

}
//! endzinc
