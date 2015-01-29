library PlayerState 
//==============================================================================
//  boolean:    IsPlayerUserOnline(player whichPlayer)
//  boolean:    IsPlayerComputerOnline(player whichPlayer)
//==============================================================================

    function IsPlayerUserOnline takes player p returns boolean
        return ((GetPlayerController(p) == MAP_CONTROL_USER) and (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING))
    endfunction
    
    function IsPlayerComputerOnline takes player p returns boolean
        return ((GetPlayerController(p) == MAP_CONTROL_COMPUTER) and (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING))
    endfunction
endlibrary
