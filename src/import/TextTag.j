//==============================================================================
//  TEXT TAG - Floating text system by Cohadar - v5.0
//==============================================================================
//
//  PURPOUSE:
//       * Displaying floating text - the easy way
//       * Has a set of useful and commonly needed texttag functions
//  
//  CREDITS:
//       * DioD - for extracting proper color, fadepoint and lifespan parameters
//         for default warcraft texttags (from miscdata.txt)
//
//  HOW TO IMPORT:
//       * Just create a trigger named TextTag
//         convert it to text and replace the whole trigger text with this one
//==============================================================================

library TextTag

globals    
    // for custom centered texttags
    private constant real MEAN_CHAR_WIDTH = 5.5
    private constant real MAX_TEXT_SHIFT = 200.0
    private constant real DEFAULT_HEIGHT = 16.0

    // for default texttags
    /*private constant real   SIGN_SHIFT = 16.0*/
    private constant real   FONT_SIZE = 0.024
    /*private constant string MISS = "miss"*/
    
    // Critical Strike
    private constant string ASTERISK = "*"
endglobals
/*
//===========================================================================
//   Custom centered texttag on (x,y) position
//   color is in default wc3 format, for example "|cFFFFCC00"
//===========================================================================
public function XY takes real x, real y, string text, string color returns nothing
    local texttag tt = CreateTextTag()
    local real shift = RMinBJ(StringLength(text)*MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
    call SetTextTagText(tt, color+text, FONT_SIZE)
    call SetTextTagPos(tt, x-shift, y, DEFAULT_HEIGHT)
    call SetTextTagVelocity(tt, 0.0, 0.04)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 2.5)
    call SetTextTagLifespan(tt, 4.0)
    call SetTextTagPermanent(tt, false)
    set tt = null
endfunction*/
/*
//===========================================================================
//   Custom centered texttag above unit
//===========================================================================
public function Unit takes unit whichUnit, string text, string color returns nothing
    local texttag tt = CreateTextTag()
    local real shift = RMinBJ(StringLength(text)*MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
    call SetTextTagText(tt, color+text, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit)-shift, GetUnitY(whichUnit), DEFAULT_HEIGHT)
    call SetTextTagVelocity(tt, 0.0, 0.04)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 2.5)
    call SetTextTagLifespan(tt, 4.0)
    call SetTextTagPermanent(tt, false)    
    set tt = null
endfunction*/

//===========================================================================
//   Damage
//===========================================================================
public function Damage takes unit whichUnit, string text, boolean bold returns nothing
    local texttag tt = CreateTextTag()
    local real shift = RMinBJ(StringLength(text)*MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
    if (bold) then
        call SetTextTagText(tt, "|cffff0000" + text + "|r", FONT_SIZE * 1.2)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-shift * 1.3, GetUnitY(whichUnit), DEFAULT_HEIGHT)
    else
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-shift, GetUnitY(whichUnit), DEFAULT_HEIGHT)
    endif
    call SetTextTagVelocity(tt, 0.0, 0.07)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 1.5)
    call SetTextTagLifespan(tt, 2.5)
    call SetTextTagPermanent(tt, false)    
    set tt = null
endfunction

//===========================================================================
//   Heal
//===========================================================================
public function Heal takes unit whichUnit, string text, boolean bold returns nothing
    local texttag tt = CreateTextTag()
    local real shift = RMinBJ(StringLength(text)*MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
    if (bold) then
        call SetTextTagText(tt, text, FONT_SIZE * 1.2)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-shift * 1.3, GetUnitY(whichUnit), DEFAULT_HEIGHT)
    else 
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-shift, GetUnitY(whichUnit), DEFAULT_HEIGHT)
    endif
    call SetTextTagColor(tt, 0, 255, 0, 255)
    call SetTextTagVelocity(tt, 0.0, -0.07)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 1.5)
    call SetTextTagLifespan(tt, 2.5)
    call SetTextTagPermanent(tt, false)    
    set tt = null
endfunction
/*
//===========================================================================
//  Standard wc3 gold bounty texttag, displayed only to killing player 
//===========================================================================
public function GoldBounty takes unit whichUnit, integer bounty, player killer returns nothing
    local texttag tt = CreateTextTag()
    local string text = "+" + I2S(bounty)
    call SetTextTagText(tt, text, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit)-SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
    call SetTextTagColor(tt, 255, 220, 0, 255)
    call SetTextTagVelocity(tt, 0.0, 0.03)
    call SetTextTagVisibility(tt, GetLocalPlayer()==killer)
    call SetTextTagFadepoint(tt, 2.0)
    call SetTextTagLifespan(tt, 3.0)
    call SetTextTagPermanent(tt, false)
    set text = null
    set tt = null
endfunction*/
/*
//==============================================================================
public function LumberBounty takes unit whichUnit, integer bounty, player killer returns nothing
    local texttag tt = CreateTextTag()
    local string text = "+" + I2S(bounty)
    call SetTextTagText(tt, text, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit)-SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
    call SetTextTagColor(tt, 0, 200, 80, 255)
    call SetTextTagVelocity(tt, 0.0, 0.03)
    call SetTextTagVisibility(tt, GetLocalPlayer()==killer)
    call SetTextTagFadepoint(tt, 2.0)
    call SetTextTagLifespan(tt, 3.0)
    call SetTextTagPermanent(tt, false)
    set text = null
    set tt = null
endfunction*/
/*
//===========================================================================
public function ManaBurn takes unit whichUnit, integer dmg returns nothing
    local texttag tt = CreateTextTag()
    local string text = "-" + I2S(dmg)
    call SetTextTagText(tt, text, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit)-SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
    call SetTextTagColor(tt, 82, 82 ,255 ,255)
    call SetTextTagVelocity(tt, 0.0, 0.04)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 2.0)
    call SetTextTagLifespan(tt, 5.0)
    call SetTextTagPermanent(tt, false)    
    set text = null
    set tt = null
endfunction*/
/*
//===========================================================================
public function Miss takes unit whichUnit returns nothing
    local texttag tt = CreateTextTag()
    call SetTextTagText(tt, MISS, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    call SetTextTagColor(tt, 255, 0, 0, 255)
    call SetTextTagVelocity(tt, 0.0, 0.03)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 1.0)
    call SetTextTagLifespan(tt, 3.0)
    call SetTextTagPermanent(tt, false)
    set tt = null
endfunction*/
/*
//===========================================================================
public function CriticalStrike takes unit whichUnit, integer dmg returns nothing
    local texttag tt = CreateTextTag()
    local string text = I2S(dmg) + "!"
    call SetTextTagText(tt, text, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    call SetTextTagColor(tt, 255, 0, 0, 255)
    call SetTextTagVelocity(tt, 0.0, 0.04)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 2.0)
    call SetTextTagLifespan(tt, 5.0)
    call SetTextTagPermanent(tt, false)
    set text = null
    set tt = null    
endfunction*/
/*
//===========================================================================
public function ShadowStrike takes unit whichUnit, integer dmg, boolean initialDamage returns nothing
    local texttag tt = CreateTextTag()
    local string text = I2S(dmg)
    if initialDamage then
        set text = text + "!"
    endif
    call SetTextTagText(tt, text, FONT_SIZE)
    call SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    call SetTextTagColor(tt, 160, 255, 0, 255)
    call SetTextTagVelocity(tt, 0.0, 0.04)
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, 2.0)
    call SetTextTagLifespan(tt, 5.0)
    call SetTextTagPermanent(tt, false)    
    set text = null
    set tt = null
endfunction*/


endlibrary
