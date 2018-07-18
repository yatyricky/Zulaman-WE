library RegionalFog requires ListModule

    /**** RegionalFog 1.1b by Opossum ************************************************
    RegionalFog is a vJass system that enables an easy syntax to create fogs across
    certain rects and optionally add day/night cycles to them. To set up a fog
    you first have to declare a fogData which includes the final values for the
    created fog:
    
        local fogData fd = fogData.create()
        
    You can then change any of its members independently:
    
        set fd.zStart = 2500
        set fd.green = 1
        
    Unaltered members will just use the default values below (-> struct fogData).
    When you are done setting up the fogData you create the fog itself.
    There are two different types of fogs:
        
      - Rect Fogs created by:
            local fog f = fog.createFromRect(fogData dayData, rect where)
        or by using coordinates directly:
            local fog f = fog.create(fogData dayData, real minX, real maxX, real minY, real maxY)
        
      - Circular Fogs created by
            local fog f = fog.createCircular(fogData dayData, real centerX, real centerY, real radius)
            
    Rects can be destroyed after creating a fog if you do not need them anymore. However,
    fogDatas may not be destroyed as long as their parent fog(s) are still in use.
    You can safely use a single fogData for multiple fogs, though.
    
    Fog structs feature a blendWidth value that determines a transition zone in which
    fog values are smoothly blended into each other to make it feel more natural.
    By default blendWidth is set to 0 meaning that as soon as you enter a fog's range
    its values are applied immediately.
    Positive blendWidth values add the transition zone to the rect while negative values
    will let the transition zone go inwards:
    
        set f.blendWidth = 500 //going outwards
        set f.blendWidth = -500 //going inwards
    
    If you want a fog to be dynamic and change depending on daytime you can add another
    fogData to it that will be used as the midnight fog setting.
    
        set f.nightData = fd2
    
    This will cause the system to smoothly blend day and night settings into each other
    over fogData.TRANSITION_DURATION ingame hours.
    If you want a fog to not be dynamic anymore set the nightData pointer to 0 again:
    
        set f.nightData = 0
        
    Any of a fog's or fogData's non-static members can be modified at any time without
    breaking the system.
    If no fog is set up for the current camera position or the fogs affecting this point
    are too "thin", a default fog will be added to that point. Think of it like a
    background layer in paint programs that is only visible if above layers are too
    transparent. The default fog values can be modified below by changing fogData's
    default values.
    
    You can access (readonly) these values and also the current fog values via two static
    fog members "defaultFog" and "currentFog".
    
        call BJDebugMsg("default fog zStart = "+R2S(fog.defaultFog.zStart))
        call BJDebugMsg("current fog zStart = "+R2S(fog.currentFog.zStart))
    
    Keep in mind that currentFog's members are asynchronous and should only be used in
    code that does not cause net traffic. Using it in global code might cause desyncs.
    -----------------------------------------------------------------------------------
    This system requires vJass and ListModule by grim001.
    ********************************************************************************/
    
    struct fogData
        // Calibration
        static constant real SAMPLE_RATE         = 0.02 /* Determines the interval during
                                                           which the camera position is
                                                           sampled and the global fog is
                                                           updated. Lower values may lower
                                                           performance. */
        static constant real TRANSITION_DURATION = 6 /* Determines the duration of a
                                                        day/night transition centered
                                                        at 6 am/pm.
                                                        Example: If set to 6 the system
                                                        will start to blend from night
                                                        to day settings at 3 am and will
                                                        finish at 9 am (= 6 ingame hours). */
        real zStart = 2000
        real zEnd   = 3000
        real red    = 0
        real green  = 0
        real blue   = 0
        // End of calibration. Don't change anything below!
    endstruct
    
    struct fog
        readonly static fogData defaultData
        readonly static fogData currentData
        readonly static real dawnStart
        readonly static real dawnEnd
        readonly static real duskStart
        readonly static real duskEnd
        
        fogData dayData
        fogData nightData = 0
        
        readonly boolean circular = false
        
        real blendWidth = 0
        real minX // not used if circular
        real maxX // not used if circular
        real minY // not used if circular
        real maxY // not used if circular
        real centerX // not used if rectangular
        real centerY // not used if rectangular
        real radius  // not used if rectangular
        
        implement List
        
        static method create takes fogData dayData, real minX, real maxX, real minY, real maxY returns fog
            local fog f = fog.allocate()
            
            set f.dayData = dayData
            set f.minX    = minX
            set f.maxX    = maxX
            set f.minY    = minY
            set f.maxY    = maxY
            
            call f.listAdd()
            
            return f
        endmethod
        
        static method createFromRect takes fogData dayData, rect where returns fog
            local fog f = fog.allocate()
            
            set f.dayData = dayData
            set f.minX    = GetRectMinX(where)
            set f.maxX    = GetRectMaxX(where)
            set f.minY    = GetRectMinY(where)
            set f.maxY    = GetRectMaxY(where)
            
            call f.listAdd()
            
            return f
        endmethod
        
        static method createCircular takes fogData dayData, real centerX, real centerY, real radius returns fog
            local fog f = fog.allocate()
            
            set f.dayData  = dayData
            set f.centerX  = centerX
            set f.centerY  = centerY
            set f.radius   = radius
            set f.circular = true
            
            call f.listAdd()
            
            return f
        endmethod
        
        method onDestroy takes nothing returns nothing
            call .listRemove()
        endmethod
        
        static method sample takes nothing returns nothing
            local fog f = .first
            local real time = GetFloatGameState(GAME_STATE_TIME_OF_DAY)
            local real x = GetCameraTargetPositionX()
            local real y = GetCameraTargetPositionY()
            local real dx
            local real dy
            local real dayratio
            local real d
            local real r = 0
            
            if (time >= .duskEnd and time < 24) or (time >= 0 and time < .dawnStart) then
                set dayratio = 0
            elseif time >= .dawnStart and time < .dawnEnd then
                set dayratio = 1/fogData.TRANSITION_DURATION * (time-6) + 0.5
            elseif time >= .dawnEnd and time < .duskStart then
                set dayratio = 1
            elseif time >= .duskStart and time < .duskEnd then
                set dayratio = 1/fogData.TRANSITION_DURATION * (18-time) + 0.5
            endif
            
            set .currentData.zStart = 0
            set .currentData.zEnd   = 0
            set .currentData.red    = 0
            set .currentData.green  = 0
            set .currentData.blue   = 0
            
            loop
                exitwhen f == 0
                
                if f.circular then
                    set dx = x-f.centerX
                    set dy = y-f.centerY
                    set d = SquareRoot(dx*dx+dy*dy)
                    
                    if f.blendWidth <= 0 then
                        if d > f.radius then
                            set d = 0
                        elseif d <= f.radius + f.blendWidth then
                            set d = 1
                        else
                            set d = 1-(f.radius+f.blendWidth-d)/f.blendWidth
                        endif
                    else
                        if d > f.radius + f.blendWidth then
                            set d = 0
                        elseif d <= f.radius then
                            set d = 1
                        else
                            set d = (f.radius+f.blendWidth-d)/f.blendWidth
                        endif
                    endif
                else
                    set dx = f.minX-x
                    set d = x-f.maxX
                    if d > dx then
                        set dx = d
                    endif
                    set dy = f.minY-y
                    set d = y-f.maxY
                    if d > dy then
                        set dy = d
                    endif
                    
                    if dx > dy then
                        set d = dx
                    else
                        set d = dy
                    endif
                    
                    if f.blendWidth >= 0 then
                        if d > f.blendWidth then
                            set d = 0
                        elseif d <= 0 then
                            set d = 1
                        else
                            set d = 1 - d/f.blendWidth
                        endif
                    elseif f.blendWidth < 0 then
                        if d <= f.blendWidth then
                            set d = 1
                        elseif d > 0 then
                            set d = 0
                        else
                            set d = d/f.blendWidth
                        endif
                    endif
                endif
                
                if d != 0 then
                    set r = r+d
                    
                    if f.nightData == 0 then
                        set .currentData.zStart = .currentData.zStart + d*f.dayData.zStart
                        set .currentData.zEnd   = .currentData.zEnd   + d*f.dayData.zEnd
                        set .currentData.red    = .currentData.red    + d*f.dayData.red
                        set .currentData.green  = .currentData.green  + d*f.dayData.green
                        set .currentData.blue   = .currentData.blue   + d*f.dayData.blue
                    else
                        set dx = d*dayratio
                        set dy = d-dx
                        
                        set .currentData.zStart = .currentData.zStart + dx*f.dayData.zStart + dy*f.nightData.zStart
                        set .currentData.zEnd   = .currentData.zEnd   + dx*f.dayData.zEnd   + dy*f.nightData.zEnd
                        set .currentData.red    = .currentData.red    + dx*f.dayData.red    + dy*f.nightData.red
                        set .currentData.green  = .currentData.green  + dx*f.dayData.green  + dy*f.nightData.green
                        set .currentData.blue   = .currentData.blue   + dx*f.dayData.blue   + dy*f.nightData.blue
                    endif
                endif
                
                set f = f.next
            endloop
            
            if r < 1 then
                set d = 1-r
                set .currentData.zStart = .currentData.zStart + d*.defaultData.zStart
                set .currentData.zEnd   = .currentData.zEnd   + d*.defaultData.zEnd
                set .currentData.red    = .currentData.red    + d*.defaultData.red
                set .currentData.green  = .currentData.green  + d*.defaultData.green
                set .currentData.blue   = .currentData.blue   + d*.defaultData.blue
                set r = 1
            else
                set .currentData.zStart = .currentData.zStart / r
                set .currentData.zEnd   = .currentData.zEnd   / r
                set .currentData.red    = .currentData.red    / r
                set .currentData.green  = .currentData.green  / r
                set .currentData.blue   = .currentData.blue   / r
            endif
            
            call SetTerrainFogEx(0, .currentData.zStart, .currentData.zEnd, 0, .currentData.red, .currentData.green, .currentData.blue)
        endmethod
        
        static method onInit takes nothing returns nothing
            local timer t = CreateTimer()
            
            set .defaultData = fogData.create()
            set .currentData = fogData.create()
            set .dawnStart = 6 - fogData.TRANSITION_DURATION/2
            set .dawnEnd   = 6 + fogData.TRANSITION_DURATION/2
            set .duskStart = 18 - fogData.TRANSITION_DURATION/2
            set .duskEnd   = 18 + fogData.TRANSITION_DURATION/2
            
            call TimerStart(t, fogData.SAMPLE_RATE, true, function thistype.sample)
            call .sample()
            
            set t = null
        endmethod
        
    endstruct
    
endlibrary