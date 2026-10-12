SF__ = SF__ or {}
function SF__.TypeIs__(obj, target)
    if obj == nil then return false end
    local type = obj.__sf_type
    while type ~= nil do
        if type == target then return true end
        if type.__sf_interfaces ~= nil and type.__sf_interfaces[target] then return true end
        type = type.__sf_base
    end
    return false
end

function SF__.TypeAs__(obj, target)
    if SF__.TypeIs__(obj, target) then return obj end
    return nil
end

function SF__.StrConcat__(...)
    local result = ""
    for i = 1, select("#", ...) do
        local part = select(i, ...)
        if part ~= nil then
            result = result .. tostring(part)
        end
    end
    return result
end

SF__.CorTimerPool__ = SF__.CorTimerPool__ or {}
SF__.CorTimerPoolSize__ = SF__.CorTimerPoolSize__ or 0
SF__.CorMaxTimerPoolSize__ = SF__.CorMaxTimerPoolSize__ or 256

function SF__.CorAcquireTimer__()
    local size = SF__.CorTimerPoolSize__
    if size > 0 then
        local timer = SF__.CorTimerPool__[size]
        SF__.CorTimerPool__[size] = nil
        SF__.CorTimerPoolSize__ = size - 1
        return timer
    end
    return CreateTimer()
end

function SF__.CorReleaseTimer__(timer)
    PauseTimer(timer)
    local size = SF__.CorTimerPoolSize__
    if size < SF__.CorMaxTimerPoolSize__ then
        size = size + 1
        SF__.CorTimerPool__[size] = timer
        SF__.CorTimerPoolSize__ = size
    else
        DestroyTimer(timer)
    end
end

function SF__.CorRun__(fn)
    local thread = coroutine.create(fn)
    local ok, err = coroutine.resume(thread)
    if not ok then error(err) end
    return thread
end

function SF__.CorWait__(milliseconds)
    if milliseconds <= 0 then return end
    local thread = coroutine.running()
    if thread == nil then error("CorWait must be called from a coroutine") end
    if coroutine.isyieldable ~= nil and not coroutine.isyieldable() then error("CorWait cannot yield from this context") end
    local timer = SF__.CorAcquireTimer__()
    TimerStart(timer, milliseconds / 1000, false, function()
        local ok, err = coroutine.resume(thread)
        SF__.CorReleaseTimer__(timer)
        if not ok then print(tostring(err)) end
    end)
    return coroutine.yield()
end

function SF__.StrSplit__(str, sep)
    local result = {}
    if str == nil or str == "" then return result end
    if sep == nil or sep == "" then
        for i = 1, #str do
            result[i] = str:sub(i, i)
        end
        return result
    end
    local pos = 1
    while true do
        local start, finish = string.find(str, sep, pos, true)
        if start == nil then
            table.insert(result, string.sub(str, pos))
            break
        end
        table.insert(result, string.sub(str, pos, start - 1))
        pos = finish + 1
    end
    return result
end

-- UnitVec3Mode
SF__.UnitVec3Mode = SF__.UnitVec3Mode or {}
SF__.UnitVec3Mode.ForceFlying = 0
SF__.UnitVec3Mode.ForceGround = 1
-- <summary>
-- Flying units fly, ground units grounded.
-- </summary>
--
SF__.UnitVec3Mode.Auto = 2

-- Component
SF__.Component = SF__.Component or {}
SF__.Component.Name = "Component"
SF__.Component.FullName = "Component"
function SF__.Component:GetInspectorText()
    return ""
end

function SF__.Component:Awake()
end

function SF__.Component:OnEnable()
end

function SF__.Component:Start()
end

function SF__.Component:Update()
end

function SF__.Component:LateUpdate()
end

function SF__.Component:OnDisable()
end

function SF__.Component:OnDestroy()
end

function SF__.Component.__Init(self)
    self.__sf_type = SF__.Component
    self.gameObject = nil
end

function SF__.Component.New()
    local self = setmetatable({}, { __index = SF__.Component })
    SF__.Component.__Init(self)
    return self
end
-- Const
SF__.Const = SF__.Const or {}
SF__.Const.Name = "Const"
SF__.Const.FullName = "Const"
function SF__.Const.__Init(self)
    self.__sf_type = SF__.Const
end

function SF__.Const.New()
    local self = setmetatable({}, { __index = SF__.Const })
    SF__.Const.__Init(self)
    return self
end

SF__.Const.DT = 20
-- Creature
SF__.Creature = SF__.Creature or {}
SF__.Creature.Name = "Creature"
SF__.Creature.FullName = "Creature"
setmetatable(SF__.Creature, { __index = SF__.Component })
SF__.Creature.__sf_base = SF__.Component
function SF__.Creature:Cry()
    BJDebugMsg("Creature is crying")
end

function SF__.Creature:Update()
    self:Cry()
end

function SF__.Creature.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Creature
end

function SF__.Creature.New()
    local self = setmetatable({}, { __index = SF__.Creature })
    SF__.Creature.__Init(self)
    return self
end
-- Dog
SF__.Dog = SF__.Dog or {}
SF__.Dog.Name = "Dog"
SF__.Dog.FullName = "Dog"
setmetatable(SF__.Dog, { __index = SF__.Creature })
SF__.Dog.__sf_base = SF__.Creature
function SF__.Dog:Cry()
    BJDebugMsg("Dog is barking")
end

function SF__.Dog.__Init(self)
    SF__.Creature.__Init(self)
    self.__sf_type = SF__.Dog
end

function SF__.Dog.New()
    local self = setmetatable({}, { __index = SF__.Dog })
    SF__.Dog.__Init(self)
    return self
end
-- <summary>
-- A basic list backed by a Lua sequential table.
-- Uses table.insert/table.remove for array operations.
-- C# indexer (0-based) maps to Lua table (1-based) via get_Item/set_Item.
-- </summary>
--
SF__.StdLib = SF__.StdLib or {}
-- StdLib.List
SF__.StdLib.List = SF__.StdLib.List or {}
SF__.StdLib.List.Name = "List"
SF__.StdLib.List.FullName = "StdLib.List"
function SF__.StdLib.List.__Init__0(self)
    self.__sf_type = SF__.StdLib.List
    self._items = nil
    self._version = 0
    self.Count = 0
    self._items = {}
    self._version = 0
    self.Count = 0
end

function SF__.StdLib.List.New__0()
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__0(self)
    return self
end

function SF__.StdLib.List.__Init__xqm20z(self, collection)
    SF__.StdLib.List.__Init__0(self)
    do
        local collection1 = collection
        for _, item in (SF__.StdLib.List.IpairsNext)(collection1) do
            repeat
                table.insert(self._items, item)
                self.Count = (self.Count + 1)
            until true
        end
    end
end

function SF__.StdLib.List.New__xqm20z(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__xqm20z(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index7)
    if ((index7 < 0) or (index7 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index7 + 1)]
end

function SF__.StdLib.List:set_Item(index8, value9)
    if ((index8 < 0) or (index8 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index8 + 1)] = value9
end

function SF__.StdLib.List:AddRange(collection10)
    do
        local collection2 = collection10
        for _, item11 in (SF__.StdLib.List.IpairsNext)(collection2) do
            repeat
                table.insert(self._items, item11)
                self.Count = (self.Count + 1)
            until true
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item12)
    table.insert(self._items, item12)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item13)
    local index14 = self:IndexOf(item13)
    if (index14 < 0) then
        return false
    end
    self:RemoveAt(index14)
    return true
end

function SF__.StdLib.List:RemoveAt(index15)
    table.remove(self._items, (index15 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item16)
    do
        local i = 0
        while (i < self.Count) do
            repeat
                local current = self._items[(i + 1)]
                if (current == item16) then
                    return i
                end
            until true
            i = (i + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a, b)
    if (a == b) then
        return 0
    end
    if (a < b) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version17 = self._version
    table.sort(self._items, function(a20, b21)
        return (comparison(a20, b21) < 0)
    end)
    if (version17 ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version22 = self._version
    local index23 = 0
    return function()
        if (version22 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index23 = (index23 + 1)
        local value24 = self._items[index23]
        if (value24 == nil) then
            return nil
        end
        return index23, value24
    end
end

function SF__.StdLib.List:GetEnumerator()
    return nil
end
-- Math
SF__.Math = SF__.Math or {}
SF__.Math.Name = "Math"
SF__.Math.FullName = "Math"
function SF__.Math.FuzzyEquals(a51, b52, epsilon)
    if epsilon == nil then epsilon = 0.0001 end
    if (math.abs((a51 - b52)) > epsilon) then
        error(SF__.StrConcat__("SF__E2e5944b8", SF__.StrConcat__("FuzzyEquals failed: ", a51, " != ", b52)))
    end
end

function SF__.Math.Bezier3(t, c1, c2, c3)
    local t1 = (1 - t)
    return ((((t1 * t1) * c1) + (((2 * t1) * t) * c2)) + ((t * t) * c3))
end

function SF__.Math.Clamp(value53, min, max)
    if (value53 < min) then
        return min
    elseif (value53 > max) then
        return max
    else
        return value53
    end
end

function SF__.Math.Clamp01(value54)
    return SF__.Math.Clamp(value54, 0, 1)
end

function SF__.Math.Sign(value55)
    if (value55 >= 0) then
        return 1
    else
        return (-1)
    end
end

function SF__.Math.Lerp(a56, b57, t58)
    return (a56 + ((b57 - a56) * SF__.Math.Clamp01(t58)))
end

function SF__.Math.MoveTowards(current59, target, maxDelta)
    if (math.abs((target - current59)) <= maxDelta) then
        return target
    end
    return (current59 + (SF__.Math.Sign((target - current59)) * maxDelta))
end

function SF__.Math.__Init(self)
    self.__sf_type = SF__.Math
end

function SF__.Math.New()
    local self = setmetatable({}, { __index = SF__.Math })
    SF__.Math.__Init(self)
    return self
end
-- Helper
SF__.Helper = SF__.Helper or {}
SF__.Helper.Name = "Helper"
SF__.Helper.FullName = "Helper"
function SF__.Helper.SetUnitFlyable(u)
    UnitAddAbility(u, SF__.Helper._abilIdAmrf)
    UnitRemoveAbility(u, SF__.Helper._abilIdAmrf)
end

function SF__.Helper.__Init(self)
    self.__sf_type = SF__.Helper
end

function SF__.Helper.New()
    local self = setmetatable({}, { __index = SF__.Helper })
    SF__.Helper.__Init(self)
    return self
end

SF__.Helper._abilIdAmrf = FourCC("Amrf")
-- Vector3
SF__.Vector3 = SF__.Vector3 or {}
SF__.Vector3.Name = "Vector3"
SF__.Vector3.FullName = "Vector3"
function SF__.Vector3.get_zero()
    return 0, 0, 0
end

function SF__.Vector3.get_up()
    return 0, 0, 1
end

function SF__.Vector3.get_down()
    return 0, 0, (-1)
end

function SF__.Vector3.get_right()
    return 1, 0, 0
end

function SF__.Vector3.get_left()
    return (-1), 0, 0
end

function SF__.Vector3.get_forward()
    return 0, 1, 0
end

function SF__.Vector3.get_back()
    return 0, (-1), 0
end

function SF__.Vector3.get_one()
    return 1, 1, 1
end

function SF__.Vector3.op_Addition(a__x100, a__y101, a__z102, b__x103, b__y104, b__z105)
    return (a__x100 + b__x103), (a__y101 + b__y104), (a__z102 + b__z105)
end

function SF__.Vector3.op_UnaryNegation(a__x106, a__y107, a__z108)
    return (-a__x106), (-a__y107), (-a__z108)
end

function SF__.Vector3.op_Subtraction(a__x109, a__y110, a__z111, b__x112, b__y113, b__z114)
    return (a__x109 - b__x112), (a__y110 - b__y113), (a__z111 - b__z114)
end

function SF__.Vector3.op_Multiply__osef(v__x115, v__y116, v__z117, f)
    return (v__x115 * f), (v__y116 * f), (v__z117 * f)
end

function SF__.Vector3.op_Multiply__fose(f118, v__x119, v__y120, v__z121)
    return (v__x119 * f118), (v__y120 * f118), (v__z121 * f118)
end

function SF__.Vector3.op_Division(v__x122, v__y123, v__z124, f125)
    return (v__x122 / f125), (v__y123 / f125), (v__z124 / f125)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x126, a__y127, a__z128, b__x129, b__y130, b__z131)
    return ((a__y127 * b__z131) - (a__z128 * b__y130)), ((a__z128 * b__x129) - (a__x126 * b__z131)), ((a__x126 * b__y130) - (a__y127 * b__x129))
end

function SF__.Vector3.Distance(a__x132, a__y133, a__z134, b__x135, b__y136, b__z137)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x132, a__y133, a__z134, b__x135, b__y136, b__z137))
end

function SF__.Vector3.Dot(a__x138, a__y139, a__z140, b__x141, b__y142, b__z143)
    return (((a__x138 * b__x141) + (a__y139 * b__y142)) + (a__z140 * b__z143))
end

function SF__.Vector3.Lerp(a__x144, a__y145, a__z146, b__x147, b__y148, b__z149, t150)
    t150 = SF__.Math.Clamp01(t150)
    return SF__.Vector3.op_Addition(a__x144, a__y145, a__z146, (function()
        local v__x151, v__y152, v__z153 = SF__.Vector3.op_Subtraction(b__x147, b__y148, b__z149, a__x144, a__y145, a__z146)
        return SF__.Vector3.op_Multiply__osef(v__x151, v__y152, v__z153, t150)
    end)())
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x154, v__y155, v__z156, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x154, v__y155, v__z156, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x157, v__y158, v__z159, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x157, v__y158, v__z159, SF__.Vector3.Project(v__x157, v__y158, v__z159, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x160, current__y161, current__z162, target__x163, target__y164, target__z165, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x160, current__y161, current__z162)
    local targetMag = SF__.Vector3.get_magnitude(target__x163, target__y164, target__z165)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x160, current__y161, current__z162, target__x163, target__y164, target__z165, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x160, current__y161, current__z162, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x163, target__y164, target__z165, targetMag)
    local dot166 = SF__.Math.Clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle = math.acos(dot166)
    if (angle == 0) then
        return SF__.Vector3.MoveTowards(current__x160, current__y161, current__z162, target__x163, target__y164, target__z165, maxMagnitudeDelta)
    end
    local t167 = math.min(1, (maxRadiansDelta / angle))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t167)
    local newMag = SF__.Math.MoveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x168, a__y169, a__z170, b__x171, b__y172, b__z173)
    return (a__x168 * b__x171), (a__y169 * b__y172), (a__z170 * b__z173)
end

function SF__.Vector3.Slerp(a__x174, a__y175, a__z176, b__x177, b__y178, b__z179, t180)
    local magA = SF__.Vector3.get_magnitude(a__x174, a__y175, a__z176)
    local magB = SF__.Vector3.get_magnitude(b__x177, b__y178, b__z179)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x174, a__y175, a__z176, b__x177, b__y178, b__z179, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x174, a__y175, a__z176, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x177, b__y178, b__z179, magB)
    local dot181 = SF__.Math.Clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle182 = math.acos(dot181)
    local sinAngle = math.sin(angle182)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x174, a__y175, a__z176, b__x177, b__y178, b__z179, math.huge)
    end
    local tAngle = (angle182 * t180)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle182 - tAngle))
    local newDir__x189, newDir__y190, newDir__z191 = (function()
        local v__x186, v__y187, v__z188 = (function()
            local a__x183, a__y184, a__z185 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x183, a__y184, a__z185, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x186, v__y187, v__z188, sinAngle)
    end)()
    local newMag192 = SF__.Math.Lerp(magA, magB, t180)
    return SF__.Vector3.op_Multiply__osef(newDir__x189, newDir__y190, newDir__z191, newMag192)
end

function SF__.Vector3._getTerrainZ(x193, y194)
    MoveLocation(SF__.Vector3._loc, x193, y194)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u195)
    local x196 = GetUnitX(u195)
    local y197 = GetUnitY(u195)
    return x196, y197, (SF__.Vector3._getTerrainZ(x196, y197) + GetUnitFlyHeight(u195))
end

function SF__.Vector3.get_sqrMagnitude(self__x198, self__y199, self__z200)
    return (((self__x198 * self__x198) + (self__y199 * self__y199)) + (self__z200 * self__z200))
end

function SF__.Vector3.get_magnitude(self__x201, self__y202, self__z203)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x201, self__y202, self__z203))
end

function SF__.Vector3.get_normalized(self__x204, self__y205, self__z206)
    local mag = SF__.Vector3.get_magnitude(self__x204, self__y205, self__z206)
    if (mag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x204, self__y205, self__z206, mag)
end

function SF__.Vector3.ClampMagnitude(self__x210, self__y211, self__z212, mag213)
    return (function()
        local v__x214, v__y215, v__z216 = SF__.Vector3.get_normalized(self__x210, self__y211, self__z212)
        return SF__.Vector3.op_Multiply__osef(v__x214, v__y215, v__z216, mag213)
    end)()
end

function SF__.Vector3.ToString(self__x217, self__y218, self__z219)
    return SF__.StrConcat__("(", self__x217, ", ", self__y218, ", ", self__z219, ")")
end

function SF__.Vector3.UnitMoveTo(self__x220, self__y221, self__z222, u223, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x220, self__y221)
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u223)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u223, self__x220, self__y221)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            SF__.Helper.SetUnitFlyable(u223)
            SetUnitFlyHeight(u223, (math.max(minZ, self__z222) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u223, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u223, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u223, (math.max(minZ, self__z222) - minZ), 0)
            else
                SetUnitFlyHeight(u223, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x224, self__y225, self__z226)
    return SF__.Vector3._getTerrainZ(self__x224, self__y225)
end

SF__.Vector3._loc = Location(0, 0)
-- Quaternion
SF__.Quaternion = SF__.Quaternion or {}
SF__.Quaternion.Name = "Quaternion"
SF__.Quaternion.FullName = "Quaternion"
function SF__.Quaternion.get_identity()
    return 0, 0, 0, 1
end

function SF__.Quaternion.op_Multiply__iyiiyi(a__x, a__y, a__z, a__w, b__x, b__y, b__z, b__w)
    return ((((a__w * b__x) + (a__x * b__w)) + (a__y * b__z)) - (a__z * b__y)), ((((a__w * b__y) - (a__x * b__z)) + (a__y * b__w)) + (a__z * b__x)), ((((a__w * b__z) + (a__x * b__y)) - (a__y * b__x)) + (a__z * b__w)), ((((a__w * b__w) - (a__x * b__x)) - (a__y * b__y)) - (a__z * b__z))
end

function SF__.Quaternion.op_Multiply__iyiose(q__x60, q__y61, q__z62, q__w63, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x60, q__y61, q__z62
    local s = q__w63
    return (function()
        local a__x67, a__y68, a__z69 = (function()
            local a__x64, a__y65, a__z66 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x64, a__y65, a__z66, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x67, a__y68, a__z69, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
    end)()
end

function SF__.Quaternion.Euler(pitch, yaw, roll)
    pitch = (pitch * bj_DEGTORAD)
    yaw = (yaw * bj_DEGTORAD)
    roll = (roll * bj_DEGTORAD)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local cy = math.cos((yaw * 0.5))
    local sy = math.sin((yaw * 0.5))
    local cp = math.cos((pitch * 0.5))
    local sp = math.sin((pitch * 0.5))
    local cr = math.cos((roll * 0.5))
    local sr = math.sin((roll * 0.5))
    return (((sr * cp) * cy) - ((cr * sp) * sy)), (((cr * sp) * cy) + ((sr * cp) * sy)), (((cr * cp) * sy) - ((sr * sp) * cy)), (((cr * cp) * cy) + ((sr * sp) * sy))
end

function SF__.Quaternion.LookRotation__oseose(forward__x, forward__y, forward__z, upwards__x, upwards__y, upwards__z)
    local worldForward__x, worldForward__y, worldForward__z = SF__.Vector3.get_normalized(forward__x, forward__y, forward__z)
    if (SF__.Vector3.get_sqrMagnitude(worldForward__x, worldForward__y, worldForward__z) < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    local worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.get_normalized(SF__.Vector3.ProjectOnPlane(upwards__x, upwards__y, upwards__z, worldForward__x, worldForward__y, worldForward__z))
    if (SF__.Vector3.get_sqrMagnitude(worldUp__x, worldUp__y, worldUp__z) < 0.0001) then
        local fallbackUp__x, fallbackUp__y, fallbackUp__z
        do
            if (math.abs(worldForward__z) < 0.999) then
                fallbackUp__x, fallbackUp__y, fallbackUp__z = SF__.Vector3.get_up()
            else
                fallbackUp__x, fallbackUp__y, fallbackUp__z = SF__.Vector3.get_right()
            end
        end
        worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.get_normalized(SF__.Vector3.ProjectOnPlane(fallbackUp__x, fallbackUp__y, fallbackUp__z, worldForward__x, worldForward__y, worldForward__z))
    end
    local worldRight__x, worldRight__y, worldRight__z = SF__.Vector3.get_normalized(SF__.Vector3.Cross(worldForward__x, worldForward__y, worldForward__z, worldUp__x, worldUp__y, worldUp__z))
    worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.Cross(worldRight__x, worldRight__y, worldRight__z, worldForward__x, worldForward__y, worldForward__z)
    local m00 = worldRight__x
    local m01 = worldForward__x
    local m02 = worldUp__x
    local m10 = worldRight__y
    local m11 = worldForward__y
    local m12 = worldUp__y
    local m20 = worldRight__z
    local m21 = worldForward__z
    local m22 = worldUp__z
    local x
    local y
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s70 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s70)
        x = ((m21 - m12) / s70)
        y = ((m02 - m20) / s70)
        z = ((m10 - m01) / s70)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s71 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s71)
        x = (0.25 * s71)
        y = ((m01 + m10) / s71)
        z = ((m02 + m20) / s71)
    else
        if (m11 > m22) then
            local s72 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s72)
            x = ((m01 + m10) / s72)
            y = (0.25 * s72)
            z = ((m12 + m21) / s72)
        else
            local s73 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s73)
            x = ((m02 + m20) / s73)
            y = ((m12 + m21) / s73)
            z = (0.25 * s73)
        end
    end
    return SF__.Quaternion.Normalize(x, y, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x74, forward__y75, forward__z76)
    return SF__.Quaternion.LookRotation__oseose(forward__x74, forward__y75, forward__z76, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x77, q__y78, q__z79, q__w80)
    local magnitude = math.sqrt(((((q__x77 * q__x77) + (q__y78 * q__y78)) + (q__z79 * q__z79)) + (q__w80 * q__w80)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x77 / magnitude), (q__y78 / magnitude), (q__z79 / magnitude), (q__w80 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll81 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch82
    if (math.abs(sinp) >= 1) then
        pitch82 = ((SF__.Math.Sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch82 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw83 = math.atan(siny_cosp, cosy_cosp)
    return (pitch82 * bj_RADTODEG), (yaw83 * bj_RADTODEG), (roll81 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x84, self__y85, self__z86, self__w87)
    return SF__.Quaternion.Normalize(self__x84, self__y85, self__z86, self__w87)
end

function SF__.Quaternion.Inverse(rotation__x, rotation__y, rotation__z, rotation__w)
    return (-rotation__x), (-rotation__y), (-rotation__z), rotation__w
end

function SF__.Quaternion.ToString(self__x92, self__y93, self__z94, self__w95)
    return SF__.StrConcat__("(", self__x92, ", ", self__y93, ", ", self__z94, ", ", self__w95, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x96, self__y97, self__z98, self__w99, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x96, self__y97, self__z98, self__w99)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- Transform
SF__.Transform = SF__.Transform or {}
SF__.Transform.Name = "Transform"
SF__.Transform.FullName = "Transform"
setmetatable(SF__.Transform, { __index = SF__.Component })
SF__.Transform.__sf_base = SF__.Component
function SF__.Transform:get_position()
    if (self.parent == nil) then
        return self.localPosition__x, self.localPosition__y, self.localPosition__z
    end
    local globalPos__x, globalPos__y, globalPos__z = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x, globalRot__y, globalRot__z, globalRot__w = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x, globalScale__y, globalScale__z = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        repeat
            globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
            globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__iyiiyi(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
            globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
            myParent = myParent.parent
        until true
    end
    return globalPos__x, globalPos__y, globalPos__z
end

function SF__.Transform:set_position(value__x, value__y, value__z)
    if (self.parent == nil) then
        self.localPosition__x, self.localPosition__y, self.localPosition__z = value__x, value__y, value__z
        return
    end
    local pos__x, pos__y, pos__z = value__x, value__y, value__z
    local myParent25 = self.parent
    while (myParent25 ~= nil) do
        repeat
            pos__x, pos__y, pos__z = SF__.Vector3.op_Subtraction(pos__x, pos__y, pos__z, myParent25.localPosition__x, myParent25.localPosition__y, myParent25.localPosition__z)
            pos__x, pos__y, pos__z = SF__.Vector3.Scale((1 / myParent25.localScale__x), (1 / myParent25.localScale__y), (1 / myParent25.localScale__z), pos__x, pos__y, pos__z)
            pos__x, pos__y, pos__z = (function()
                local q__x, q__y, q__z, q__w = SF__.Quaternion.Inverse(myParent25.localRotation__x, myParent25.localRotation__y, myParent25.localRotation__z, myParent25.localRotation__w)
                return SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, pos__x, pos__y, pos__z)
            end)()
            myParent25 = myParent25.parent
        until true
    end
    self.localPosition__x, self.localPosition__y, self.localPosition__z = pos__x, pos__y, pos__z
end

function SF__.Transform.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Transform
    self.localPosition__x = 0
    self.localPosition__y = 0
    self.localPosition__z = 0
    self.localRotation__x = 0
    self.localRotation__y = 0
    self.localRotation__z = 0
    self.localRotation__w = 0
    self.localScale__x = 0
    self.localScale__y = 0
    self.localScale__z = 0
    self.children = SF__.StdLib.List.New__0()
    self.parent = nil
    self.localPosition__x, self.localPosition__y, self.localPosition__z = 0, 0, 0
    self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w = SF__.Quaternion.Euler(0, 0, 0)
    self.localScale__x, self.localScale__y, self.localScale__z = 1, 1, 1
end

function SF__.Transform.New()
    local self = setmetatable({}, { __index = SF__.Transform })
    SF__.Transform.__Init(self)
    return self
end

function SF__.Transform:GetInspectorText()
    return SF__.StrConcat__("Position: ", SF__.Vector3.ToString(self.localPosition__x, self.localPosition__y, self.localPosition__z), "\n", "Rotation: ", SF__.Vector3.ToString(SF__.Quaternion.get_eulerAngles(self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w)), "\n", "Scale: ", SF__.Vector3.ToString(self.localScale__x, self.localScale__y, self.localScale__z), "\n", "Children: ", self.children.Count)
end

function SF__.Transform:SetParent(newParent)
    if (self.parent ~= nil) then
        self.parent.children:Remove(self)
    end
    self.parent = newParent
    if (self.parent ~= nil) then
        self.parent.children:Add(self)
    end
end

function SF__.Transform._Find(current26, parts, index27)
    if (index27 >= #parts) then
        return current26
    end
    do
        local collection3 = current26.children
        for _, child in (SF__.StdLib.List.IpairsNext)(collection3) do
            repeat
                if (child.gameObject.name == parts[(index27 + 1)]) then
                    local found = SF__.Transform._Find(child, parts, (index27 + 1))
                    if (found ~= nil) then
                        return found
                    end
                end
            until true
        end
    end
    return nil
end

-- <summary>
-- Finds a child by name n and returns it.
-- If no child with name n can be found, null is returned. If n contains a '/' character it will access the Transform in the hierarchy like a path name.
-- </summary>
-- <param name="name"></param>
-- <returns></returns>
--
function SF__.Transform:Find(name)
    local parts28 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts28, 0)
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
function SF__.GameObject.RunGameObjects()
    return SF__.CorRun__(function()
        while true do
            repeat
                SF__.CorWait__(SF__.Const.DT)
                local count = SF__.GameObject._gameObjs.Count
                do
                    local i29 = 0
                    while (i29 < count) do
                        repeat
                            SF__.GameObject._gameObjs:get_Item(i29):Update()
                        until true
                        i29 = (i29 + 1)
                    end
                end
                do
                    local i30 = 0
                    while (i30 < count) do
                        repeat
                            SF__.GameObject._gameObjs:get_Item(i30):LateUpdate()
                        until true
                        i30 = (i30 + 1)
                    end
                end
                SF__.GameObject.FlushDestroyQueue()
            until true
        end
    end)
end

function SF__.GameObject.FlushDestroyQueue()
    do
        local i31 = 0
        while (i31 < SF__.GameObject._destroyQueue.Count) do
            repeat
                SF__.GameObject.DestroyQueued(SF__.GameObject._destroyQueue:get_Item(i31))
            until true
            i31 = (i31 + 1)
        end
    end
    SF__.GameObject._destroyQueue:Clear()
end

function SF__.GameObject.MarkDestroyQueuedDepthFirst(obj32)
    if (obj32.isDestroyQueued or obj32.isDestroyed) then
        return
    end
    obj32.isDestroyQueued = true
    do
        local collection4 = obj32.transform.children
        for _, child33 in (SF__.StdLib.List.IpairsNext)(collection4) do
            repeat
                SF__.GameObject.MarkDestroyQueuedDepthFirst(child33.gameObject)
            until true
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj34)
    if obj34.isDestroyed then
        return
    end
    local children = obj34.transform.children
    do
        local i35 = (children.Count - 1)
        while (i35 >= 0) do
            repeat
                SF__.GameObject.DestroyDepthFirst(children:get_Item(i35).gameObject)
            until true
            i35 = (i35 - 1)
        end
    end
    obj34.transform:SetParent(nil)
    do
        local collection5 = obj34._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            repeat
                comp:OnDisable()
                comp:OnDestroy()
            until true
        end
    end
    obj34._components:Clear()
    SF__.GameObject._gameObjs:Remove(obj34)
    obj34.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name36)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name36
    self.transform = self:AddComponent(SF__.Transform)
    SF__.GameObject._gameObjs:Add(self)
end

function SF__.GameObject.New__s(name36)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name36)
    return self
end

function SF__.GameObject.__Init__sx13(self, name37, parent)
    SF__.GameObject.__Init__s(self, name37)
    self.transform:SetParent(parent.transform)
end

function SF__.GameObject.New__sx13(name37, parent)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name37, parent)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp38 in (SF__.StdLib.List.IpairsNext)(collection6) do
            repeat
                do
                    local tComp = comp38
                    if SF__.TypeIs__(tComp, T) then
                        return tComp
                    end
                end
            until true
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T39)
    local comp40 = (function()
        local obj41 = T39.New()
        obj41.gameObject = self
        return obj41
    end)()
    self._components:Add(comp40)
    comp40:Awake()
    comp40:OnEnable()
    comp40:Start()
    return comp40
end

function SF__.GameObject:RemoveAllComponents(T42)
    do
        local i43 = (self._components.Count - 1)
        while (i43 >= 0) do
            repeat
                if SF__.TypeIs__(self._components:get_Item(i43), T42) then
                    self._components:get_Item(i43):OnDisable()
                    self._components:get_Item(i43):OnDestroy()
                    self._components:RemoveAt(i43)
                end
            until true
            i43 = (i43 - 1)
        end
    end
end

function SF__.GameObject:Update()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection7 = snapshot
        for _, comp44 in (SF__.StdLib.List.IpairsNext)(collection7) do
            repeat
                comp44:Update()
            until true
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot45 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot45
        for _, comp46 in (SF__.StdLib.List.IpairsNext)(collection8) do
            repeat
                comp46:LateUpdate()
            until true
        end
    end
end

function SF__.GameObject:Destroy()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    SF__.GameObject.MarkDestroyQueuedDepthFirst(self)
    SF__.GameObject._destroyQueue:Add(self)
end

function SF__.GameObject.DestroyQueued(obj47)
    SF__.GameObject.DestroyDepthFirst(obj47)
end

function SF__.GameObject:GetComponentInChildren(T48)
    do
        local collection9 = self.transform.children
        for _, child49 in (SF__.StdLib.List.IpairsNext)(collection9) do
            repeat
                local comp50 = child49.gameObject:GetComponent(T48)
                if (comp50 ~= nil) then
                    return comp50
                end
                comp50 = child49.gameObject:GetComponentInChildren(T48)
                if (comp50 ~= nil) then
                    return comp50
                end
            until true
        end
    end
    return nil
end

SF__.GameObject._gameObjs = SF__.StdLib.List.New__0()
SF__.GameObject._destroyQueue = SF__.StdLib.List.New__0()
-- Program
SF__.Program = SF__.Program or {}
SF__.Program.Name = "Program"
SF__.Program.FullName = "Program"
function SF__.Program.Main()
    SF__.GameObject.RunGameObjects()
    local obj = SF__.GameObject.New__s("Test Object")
    -- obj.AddComponent<Dog>();
end

function SF__.Program.__Init(self)
    self.__sf_type = SF__.Program
end

function SF__.Program.New()
    local self = setmetatable({}, { __index = SF__.Program })
    SF__.Program.__Init(self)
    return self
end
-- <summary>
-- A basic dictionary backed by a Lua table with direct key access.
-- C# indexer (dict[key]) maps to direct table field access via get_Item/set_Item.
-- </summary>
--
-- StdLib.Dictionary
SF__.StdLib.Dictionary = SF__.StdLib.Dictionary or {}
SF__.StdLib.Dictionary.Name = "Dictionary"
SF__.StdLib.Dictionary.FullName = "StdLib.Dictionary"
function SF__.StdLib.Dictionary.__Init(self)
    self.__sf_type = SF__.StdLib.Dictionary
    self._table = nil
    self._version = 0
    self._keys = nil
    self.Count = 0
    self._table = {}
    self._keys = SF__.StdLib.List.New__0()
    self._version = 0
    self.Count = 0
end

function SF__.StdLib.Dictionary.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary })
    SF__.StdLib.Dictionary.__Init(self)
    return self
end

function SF__.StdLib.Dictionary:get_Item(key)
    if (key == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (function()
        local __coalesce = self._table[key]
        if (__coalesce == nil) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Key not found"))
        end
        return __coalesce
    end)()
end

function SF__.StdLib.Dictionary:set_Item(key1, value)
    if (key1 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local existing = self._table[key1]
    self._table[key1] = value
    if (existing == nil) then
        self.Count = (self.Count + 1)
        self._keys:Add(key1)
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.Dictionary:PairsNext()
    local version = self._version
    local index = 0
    return function()
        if (version ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index = (index + 1)
        if (index > self._keys.Count) then
            return nil
        end
        local key2 = self._keys:get_Item((index - 1))
        local value3 = self._table[key2]
        return key2, value3
    end
end

function SF__.StdLib.Dictionary:ContainsKey(key4)
    if (key4 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (self._table[key4] ~= nil)
end

function SF__.StdLib.Dictionary:TryGetValue(key5)
    if (key5 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local result = self._table[key5]
    if (result ~= nil) then
        value6 = result
        return true, value6
    end
    value6 = nil
    return false, value6
end

function SF__.StdLib.Dictionary:GetEnumerator()
    return nil
end
SF__.StdLib.Dictionary = SF__.StdLib.Dictionary or {}
-- StdLib.Dictionary.Enumerator
SF__.StdLib.Dictionary.Enumerator = SF__.StdLib.Dictionary.Enumerator or {}
SF__.StdLib.Dictionary.Enumerator.Name = "Enumerator"
SF__.StdLib.Dictionary.Enumerator.FullName = "StdLib.Dictionary.Enumerator"
function SF__.StdLib.Dictionary.Enumerator:get_Current()
    return nil
end

function SF__.StdLib.Dictionary.Enumerator:MoveNext()
    return nil
end

function SF__.StdLib.Dictionary.Enumerator.__Init(self)
    self.__sf_type = SF__.StdLib.Dictionary.Enumerator
end

function SF__.StdLib.Dictionary.Enumerator.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary.Enumerator })
    SF__.StdLib.Dictionary.Enumerator.__Init(self)
    return self
end
SF__.StdLib.List = SF__.StdLib.List or {}
-- StdLib.List.Enumerator
SF__.StdLib.List.Enumerator = SF__.StdLib.List.Enumerator or {}
SF__.StdLib.List.Enumerator.Name = "Enumerator"
SF__.StdLib.List.Enumerator.FullName = "StdLib.List.Enumerator"
function SF__.StdLib.List.Enumerator:get_Current()
    return nil
end

function SF__.StdLib.List.Enumerator:MoveNext()
    return nil
end

function SF__.StdLib.List.Enumerator.__Init(self)
    self.__sf_type = SF__.StdLib.List.Enumerator
end

function SF__.StdLib.List.Enumerator.New()
    local self = setmetatable({}, { __index = SF__.StdLib.List.Enumerator })
    SF__.StdLib.List.Enumerator.__Init(self)
    return self
end

SF__.Program.Main()
