library SoundUtils requires Stack, TimerUtils
//******************************************************************************
//* BY: Rising_Dusk
//* 
//* Sounds are a very picky datatype in WC3. They have many quirks that one must
//* account for in order to use them, and simply using the internal WE Sound
//* Editor isn't enough because the sounds it makes can't be played multiple
//* times at once. 3-D sounds are also very tricky because there are different
//* WC3 sound options that a user can have activated where certain sounds will
//* or will not work. This library attempts to streamline the handling of sounds
//* so that it is less likely to confuse you or cause problems.
//* 
//* The .mp3 format can be used for 3-D sounds, but there is one problem that
//* must be noted. If your computer supports the "Dolby Surround" sound option
//* in WC3 and you have it selected, then .mp3 files will work for 3-D sounds.
//* If you don't, however, they may not work depending on what you do have
//* selected and what is available for your computer. The .wav format works on
//* all possible settings, making them excellent for general use. This library
//* can interface with sounds of either type.
//* 
//* Known issues with sounds that this library resolves:
//*     - A given sound variable can only be played once at a time. In order to
//*       play a sound type multiple times at once, you need multiple variables.
//*     - A sound cannot be played at the same instant that it is created.
//* 
//* The DefineSound function defines a sound type based on some basic parameters
//* the user provides. DefineSoundEx is available if the user wants control over
//* all possible parameters, though they won't have an impact most of the time.
//* The duration parameter for DefineSound and DefineSoundEx is in milliseconds,
//* which is consistent with Blizzard's natives. To get the duration of a given
//* sound, open up the WE's Sound Editor, navigate to your sound, and select
//* "Add as Sound." In doing so, it will show its duration in seconds. Multiply
//* that number by 1000 and use it as the duration argument.
//* 
//* This library returns a sound variable with RunSound that you can change the
//* settings of using the standard JASS sound API. The library assigns default
//* values to the parameters for 2-D and 3-D sounds, that way they will run
//* without any further help.
//* 
//* The library automatically allocates, runs, and recycles a sound when you
//* call RunSound. This library will not automatically recycle looping sounds,
//* so you will need to call ReleaseSound on the looping sound when you want it
//* to end.
//* 
//******************************************************************************
//* 
//*    > function DefineSound takes string fileName, integer duration, ...
//*        boolean looping, boolean is3D returns integer
//* 
//* This function defines a sound type with a short list of parameters. The
//* returned integer serves as a SOUND_TYPE for running this type of sound at
//* any other point in a map.
//* 
//*    > function DefineSoundEx takes string fileName, integer duration, ...
//*        boolean looping, boolean is3D, boolean stopwhenoutofrange, ...
//*        integer fadeInRate, integer fadeOutRate, string eaxSetting ...
//*        returns integer
//* 
//* This function serves an identical purpose to DefineSound, but gives the user
//* full control over the entire list of parameters. Similar to DefineSound, the
//* returned integer serves as a SOUND_TYPE for running this type of sound.
//* 
//*    > function RunSound takes integer soundRef returns sound
//* 
//* This function runs a sound with the parameters held within the soundRef
//* integer argument. The soundRef argument is the returned value of DefineSound
//* or DefineSoundEx.
//* 
//*    > function RunSoundOnUnit takes integer soundRef, unit whichUnit returns sound
//* 
//* The same as RunSound, just this function runs a sound of a given type on a
//* specified unit.
//* 
//*    > function RunSoundAtPoint takes integer soundRef, real x, real y, real z returns sound
//* 
//* The same as RunSound, just this function runs a sound of a given type at a
//* specified point in 3D space.
//* 
//*    > function RunSoundForPlayer takes integer soundRef, player p returns sound
//* 
//* The same as RunSound, just this function runs a sound of a given type only
//* for the specified player.
//* 
//*    > function ReleaseSound takes sound s returns boolean
//* 
//* This function need only be called on looping sounds. If a sound is not
//* looping, it will be released and recycled on its own. This function should
//* be used on looping sounds when you want them to end.
//* 
//* Example usage:
//*     set SOUND_TYPE = DefineSound("Sound\\Path.wav", 300, false, true)
//*     call RunSound(SOUND_TYPE)
//*     call RunSoundOnUnit(SOUND_TYPE, SomeUnit)
//*     call RunSoundAtPoint(SOUND_TYPE, x, y, z)
//*     call RunSoundForPlayer(SOUND_TYPE, Player(5))
//*     call ReleaseSound(SomeLoopingSound)
//* 
globals
    private hashtable ht = InitHashtable() //Attach sound types to sounds
    private hashtable st = InitHashtable() //Sound hashtable
    private hashtable rt = InitHashtable() //Attach soundrecyclers to sounds
    private hashtable kt = InitHashtable() //Attach StopSound data
endglobals

//Struct for each sound type
private struct soundhelper
    //Stack associated to each struct
    Stack   sta
    
    //Sound Settings for this sound type
    string  fileName           = ""
    integer duration           = 0
    boolean looping            = false
    boolean is3D               = false
    boolean stopwhenoutofrange = false
    integer fadeInRate         = 0
    integer fadeOutRate        = 0
    string  eaxSetting         = ""
    
    static method create takes string fileName, integer duration, boolean looping, boolean is3D, boolean stopwhenoutofrange, integer fadeInRate, integer fadeOutRate, string eaxSetting returns soundhelper
        local soundhelper sh      = soundhelper.allocate()
        //Load the parameters so the sound can be created later as necessary
        set sh.fileName           = fileName
        set sh.duration           = duration
        set sh.looping            = looping
        set sh.is3D               = is3D
        set sh.stopwhenoutofrange = stopwhenoutofrange
        set sh.fadeInRate         = fadeInRate
        set sh.fadeOutRate        = fadeOutRate
        set sh.eaxSetting         = eaxSetting
        //Create the stack for the struct
        set sh.sta                = Stack.create()
        return sh
    endmethod
endstruct

//Struct for holding data for the sound recycling
private struct soundrecycler
    timer   t       = null
    sound   s       = null
    integer sh      = 0
    boolean stopped = false //Only gets used if StopSound is called on a new sound
    
    static method create takes sound whichSound, integer soundRef returns soundrecycler
        local soundrecycler sr = soundrecycler.allocate()
        set sr.t       = NewTimer()
        set sr.s       = whichSound
        set sr.sh      = soundRef
        call SetTimerData(sr.t, integer(sr))
        
        //Hook the value to the soundRef and whichSound
        call SaveInteger(rt, soundRef, GetHandleId(whichSound), integer(sr))
        return sr
    endmethod
    private method onDestroy takes nothing returns nothing
        call RemoveSavedInteger(rt, .sh, GetHandleId(.s))
        call ReleaseTimer(.t)
    endmethod
endstruct

//******************************************************************************

private function HookStopSound takes sound soundHandle, boolean killWhenDone, boolean fadeOut returns nothing
    local integer       id       = GetHandleId(soundHandle)
    local integer       soundRef = 0
    local soundrecycler sr       = 0
    if HaveSavedInteger(ht, 0, id) then //Sound is from stacks
        set soundRef = LoadInteger(ht, 0, id)
        if HaveSavedInteger(rt, soundRef, id) then //Sound has a recycler
            set sr         = soundrecycler(LoadInteger(rt, soundRef, id))
            set sr.stopped = true
        endif
        if killWhenDone then
            debug call BJDebugMsg(SCOPE_PREFIX+"Warning: (StopSound) Destroying a sound in the stack")
        endif
    endif
endfunction

hook StopSound HookStopSound

private function HookKillSoundWhenDone takes sound soundHandle returns nothing
    if HaveSavedInteger(ht, 0, GetHandleId(soundHandle)) then
        call BJDebugMsg(SCOPE_PREFIX+"Warning: (KillSoundWhenDone) Destroying a sound in the stack")
    endif
endfunction

debug hook KillSoundWhenDone HookKillSoundWhenDone

//******************************************************************************

function DefineSoundEx takes string fileName, integer duration, boolean looping, boolean is3D, boolean stopwhenoutofrange, integer fadeInRate, integer fadeOutRate, string eaxSetting returns integer
    return integer(soundhelper.create(fileName, duration, looping, is3D, stopwhenoutofrange, fadeInRate, fadeOutRate, eaxSetting))
endfunction
function DefineSound takes string fileName, integer duration, boolean looping, boolean is3D returns integer
    return DefineSoundEx(fileName, duration, looping, is3D, true, 10, 10, "CombatSoundsEAX") //  DefaultEAXON
endfunction

function ReleaseSound takes sound s returns boolean
    local integer       id       = GetHandleId(s)
    local integer       soundRef = 0
    local soundhelper   sh       = 0
    local soundrecycler sr       = 0
    
    if s == null then
        debug call BJDebugMsg(SCOPE_PREFIX+"Error: Cannot recycle a null sound")
        return false
    elseif not HaveSavedInteger(ht, 0, id) then
        debug call BJDebugMsg(SCOPE_PREFIX+"Error: Cannot recycle a sound not allocated by RunSound")
        return false
    endif
    
    set soundRef = LoadInteger(ht, 0, id)
    set sh       = soundhelper(soundRef)
    
    call StopSound(s, false, true)             //Stop the sound
    call sh.sta.push(id)                       //Return it to the stack
    call SaveSoundHandle(st, soundRef, id,  s) //Save it to hashtable
    if not sh.looping then
        //soundrecycler only exists for non-looping sounds
        set sr = soundrecycler(LoadInteger(rt, soundRef, id))
        call sr.destroy()                      //Destroy recycler helper
    endif
    return true
endfunction

private function Recycle takes nothing returns nothing
    local soundrecycler sr = soundrecycler(GetTimerData(GetExpiredTimer()))
    local soundhelper   sh = soundhelper(sr.sh)
    local integer       id = GetHandleId(sr.s)
    
    call StopSound(sr.s, false, true)               //Stop the sound
    call sh.sta.push(id)                            //Return it to the stack
    call SaveSoundHandle(st, integer(sh), id, sr.s) //Save it to hashtable
    call sr.destroy()                               //Destroy recycler helper
endfunction

private function Run takes nothing returns nothing
    local soundrecycler sr = soundrecycler(GetTimerData(GetExpiredTimer()))
    local soundhelper   sh = soundhelper(sr.sh)
    
    if not sr.stopped then
        call StartSound(sr.s) //Play sound here
    endif
    if not sh.looping and not sr.stopped then
        call TimerStart(sr.t, sh.duration*0.001, false, function Recycle)
    else
        call sr.destroy()
    endif
endfunction

function RunSound takes integer soundRef returns sound
    local sound         s  = null
    local integer       i  = 0
    local soundhelper   sh = soundhelper(soundRef)
    local soundrecycler sr = 0
    
    if soundRef <= 0 then
        debug call BJDebugMsg(SCOPE_PREFIX+"Error: Cannot run sound of undefined type")
        return null
    endif
    //Check if the stack is empty
    if sh.sta.peek() == Stack.EMPTY then
        //Create a new sound for the stack
        set s = CreateSound(sh.fileName, sh.looping, sh.is3D, sh.stopwhenoutofrange, sh.fadeInRate, sh.fadeOutRate, sh.eaxSetting)
        //Attach the type to the sound for future reference
        call SaveInteger(ht, 0, GetHandleId(s), integer(sh))
        call SetSoundDuration(s, sh.duration)
        
        //Stuff that must be performed immediately upon creation of sounds
        call SetSoundChannel(s, 5)
        call SetSoundVolume(s, 127)
        call SetSoundPitch(s, 1.)
        if sh.is3D then
            //These are settings necessary for 3-D sounds to function properly
            //You can change them at will outside of this function
            call SetSoundDistances(s, 600., 10000.)
            call SetSoundDistanceCutoff(s, 3000.)
            call SetSoundConeAngles(s, 0., 0., 127)
            call SetSoundConeOrientation(s, 0., 0., 0.)
        endif
        
        //Start sound after a delay because it was created here
        set sr = soundrecycler.create(s, soundRef)
        call TimerStart(sr.t, 0.001, false, function Run)
    else
        //Allocate a sound from the stack
        set i = sh.sta.pop()
        if not HaveSavedHandle(st, soundRef, i) then
            debug call BJDebugMsg(SCOPE_PREFIX+"Error: No sound in given stack member")
            return null
        endif
        set s = LoadSoundHandle(st, soundRef, i)
        call RemoveSavedInteger(st, soundRef, i)
        call SetSoundVolume(s, 127) //Start volume at max
        
        //Start it here since it wasn't created here
        call StartSound(s)
        //Recycle the sound in a timer callback after it's finished if nonlooping
        if not sh.looping then
            set sr = soundrecycler.create(s, soundRef)
            call TimerStart(sr.t, sh.duration*0.001, false, function Recycle)
        endif
    endif
    return s
endfunction

function RunSoundOnUnit takes integer soundRef, unit whichUnit returns sound
    local sound s = RunSound(soundRef)
    call AttachSoundToUnit(s, whichUnit)
    return s
endfunction

function RunSoundAtPoint takes integer soundRef, real x, real y, real z returns sound
    local sound s = RunSound(soundRef)
    call SetSoundPosition(s, x, y, z)
    return s
endfunction

globals
private location tmploc = Location(0.0, 0.0)
endglobals
function RunSoundAtPoint2d takes integer soundRef, real x, real y returns sound
    call MoveLocation(tmploc, x, y)
    return RunSoundAtPoint(soundRef, x, y, GetLocationZ(tmploc))
endfunction

function RunSoundForPlayer takes integer soundRef, player p returns sound
    local sound s = RunSound(soundRef)
    if GetLocalPlayer() != p then
        call SetSoundVolume(s, 0)
    else
        call SetSoundVolume(s, 127)
    endif
    return s
endfunction
endlibrary
