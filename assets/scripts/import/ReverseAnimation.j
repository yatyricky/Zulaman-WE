library ReverseAnimation requires TimerUtils

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  ReverseAnimation
    //====================================================================================================================
    //  Firstly, this script requires TimerUtils (by Vexorian @ [url]www.wc3campaigns.net):[/url]
    //          [url]http://wc3campaigns.net/showthread.php?t=101322[/url]
    //
    //  Background Info:
    //   [url]http://www.wc3campaigns.net/showpost.php?p=1017121&postcount=88[/url]
    //
    //  function SetUnitAnimationReverse takes:
    //
    //      unit u - animation of which reverse animation is played;
    //      integer index - animation index of the animation to be played;
    //      real animTime - the natural duration of the animation to be played. This can be referred to in the preview
    //                      window in the bottom-left part of the World Editor interface (it is the real value enclosed
    //                      in parenthesis);
    //      real runSpeed - the speed at which the animation to be played in reverse will be ran.
    //      boolean resetAnim - indicates to the system if it should set the unit's animation to "stand" after playing the
    //                          reverse animation.
    //
    //  function SetUnitAnimationReverseFollowed takes all of the above and:
    //      FollowUpFunc func - function to be ran after the animation is played. Expressed as a function interface
    //                          (see below). Takes an data object arguement pertaining to relevant stuff that must be
    //                          passed.
    //      integer data - a struct that is the above data object.
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII//
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII//
//  -- Configuration --

    globals
        private constant real PREP_INTERVAL_DURATION = 0.03
    endglobals

//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII//
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII//
//  -- User Functions --

    private keyword ReverseAnimation

    function SetUnitAnimationReverse takes unit u, integer index, real animTime, real runSpeed, boolean resetAnim returns boolean
        return ReverseAnimation.Prepare(u, index, animTime, runSpeed, resetAnim, 0, 0)
    endfunction

    function SetUnitAnimationReverseFollowed takes unit u, integer index, real animTime, real runSpeed, boolean resetAnim, FollowUpFunc func, integer data returns boolean
        return ReverseAnimation.Prepare(u, index, animTime, runSpeed, resetAnim, func, data)
    endfunction

//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII//
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII//
//  -- Script Operation Functions --

    function interface FollowUpFunc takes integer data returns nothing

    private struct ReverseAnimation

        private unit u
        private integer intAnimIndex
        private real rAnimTime
        private real rRunSpeed
        private boolean boolResetAnim
        private FollowUpFunc func
        private integer data

        public static method Prepare takes unit u, integer index, real animTime, real runSpeed, boolean resetAnim, FollowUpFunc func, integer data returns boolean
            local ReverseAnimation new = 0
            local timer TIM = null

            if u != null and index > 0 and runSpeed > 0.00 then
                set new = .allocate()
                set new.u = u
                set new.intAnimIndex = index
                set new.rAnimTime = animTime
                set new.rRunSpeed = -runSpeed
                set new.boolResetAnim = resetAnim
                set new.func = func
                set new.data = data

                call SetUnitTimeScale(u, animTime/PREP_INTERVAL_DURATION)
                call SetUnitAnimationByIndex(u, index)
                set TIM = NewTimer()
                call SetTimerData(TIM, integer(new))
                call TimerStart(TIM, PREP_INTERVAL_DURATION, false, function ReverseAnimation.Play)

                set TIM = null
                return true
            endif

            return false
        endmethod

        public static method Play takes nothing returns nothing
            local timer TIM = GetExpiredTimer()
            local ReverseAnimation INST = GetTimerData(TIM)

            call SetUnitTimeScale(INST.u, INST.rRunSpeed)
            call TimerStart(TIM, INST.rAnimTime/-INST.rRunSpeed, false, function ReverseAnimation.End)

            set TIM = null
        endmethod

        public static method End takes nothing returns nothing
            local timer TIM = GetExpiredTimer()
            local ReverseAnimation INST = GetTimerData(TIM)

            call SetUnitTimeScale(INST.u, 1.00)
            if INST.boolResetAnim then
                call SetUnitAnimation(INST.u, "stand")
            endif
            if INST.func != 0 then
                call INST.func.execute(INST.data)
            endif

            set INST.u = null
            call INST.destroy()
            call ReleaseTimer(TIM)
            set TIM = null
        endmethod

    endstruct

endlibrary