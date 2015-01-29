library Stack

//*****************************************************************
//*  STACK
//*
//*  written by: Anitarf
//*
//*  This is an efficient implementation of a stack in vJass. Since
//*  it is based on a linked list, I decided to add common list
//*  methods to the data structure so it can function both as
//*  a stack and a simple linked list.
//*
//*  As a linked list, it has less functionality than Ammorth's
//*  LinkedList, but is considerably faster. Note only that most of
//*  the list methods have O(n) time complexity so they may not be
//*  suitable for operations on very large lists, however due to
//*  their simplicity the list would need to be really large for
//*  this to become a problem.
//*
//*  All stack methods are of course O(1) and as fast as possible.
//*  If you just need a stack, this is definitely the best choice.
//*
//*   set s=Stack.create()  - Instanceates a new Stack object.
//*   call s.destroy()      - Destroys the Stack.
//*
//*  Stack syntax:
//*   call s.push(123)      - Pushes the value 123 on the stack.
//*                           A stack may contain multiple
//*                           instances of the same value.
//*   set i=s.peek()        - Reads the top value of the stack
//*                           and stores it to the variable i.
//*   set i=s.pop()         - Removes the top value from the stack
//*                           and stores it to the variable i.
//*   s.peek()==Stack.EMPTY - Checks if the stack is empty.
//*
//*  List syntax:
//*   call s.add(123)       - Adds the value 123 to the list.
//*                           A list may contain multiple
//*                           instances of the same value.
//*   s.size                - The total number of values on the list.
//*   s.contains(123)       - Checks if the value 123 is on the list.
//*   set n=s.count(123)    - Stores the number of times the value
//*                           123 is on the list to the variable n.
//*   call s.remove(123)    - Removes one instance of the value 123
//*                           from the list. Returns false if
//*                           the value was not found on the list.
//*   call s.purge(123)     - Removes all instances of the value 123
//*                           from the list. Returns the number of
//*                           values that were removed.
//*   set i=s.first         - Reads the first value from the list
//*                           and stores it to the variable i.
//*   set i=s.random        - Reads a random value from the list
//*                           and stores it to the variable i.
//*   set s2=s.copy()       - Makes a copy of the list and stores
//*                           it to the variable s2.
//*   call s.enum(Func,b)   - Calls function Func for all values
//*                           on the list. The function must follow
//*                           the Enum function interface.
//*                           b is a boolean value, if it is true
//*                           then the values will be enumerated
//*                           top to bottom, if false then bottom
//*                           to top.
//*****************************************************************

    public function interface Enum takes integer value returns nothing

    struct Stack
        // Use a totally random number here, the more improbable someone uses it, the better.
        // This is the value that is returned by .pop and .peek methods and .first and .random operators when called on an empty stack.
        public static constant integer EMPTY=0x28829022

        // End of calibration.

        readonly integer size = 0
        private integer top = 0
        private static integer free = 1
        private static integer array next
        private static integer array value
        
        method push takes integer i returns nothing
            // Get an index from the list of free indexes.
            local integer n=Stack.free
            set Stack.free=Stack.next[n]
            // Extend the list of free indexes if needed.
            if Stack.free==0 then
                set Stack.free=n+1
            endif
            // Store the value to the index.
            set Stack.value[n]=i
            // Add index to the top of the stack.
            set Stack.next[n]=.top
            set .top=n
            set .size=.size+1
        endmethod
        method pop takes nothing returns integer
            // Get the top index of stack.
            local integer n=.top
            // Safety check in case a user pops an empty stack.
            if n==0 then
                debug call BJDebugMsg("stack warning: .pop called on an empty stack!")
                return Stack.EMPTY
            endif
            // Remove the top index from stack.
            set .top=Stack.next[n]
            set .size=.size-1
            // Add the index to the list of free indexes.
            set Stack.next[n]=Stack.free
            set Stack.free=n
            // Return the value.
            return Stack.value[n]
        endmethod
        method peek takes nothing returns integer
            // Read the value of the top index.
            return Stack.value[.top]
        endmethod


        method add takes integer value returns nothing
            call .push(value)
        endmethod
        method contains takes integer value returns boolean
            // Get the first index of the list.
            local integer i=.top
            // Search through the list.
            loop
                // Stop the search when the end of the list is reached.
                exitwhen i==0
                // Stop the search if the value is found.
                if Stack.value[i]==value then
                    return true
                endif
                // Get the next index of the list.
                set i=Stack.next[i]
            endloop
            return false
        endmethod
        method count takes integer value returns integer
            local integer count=0
            // Get the first index of the list.
            local integer i=.top
            // Search through the list.
            loop
                // Stop the search when the end of the list is reached.
                exitwhen i==0
                // Increase the count if the value is found.
                if Stack.value[i]==value then
                    set count=count+1
                endif
                // Get the next index of the list.
                set i=Stack.next[i]
            endloop
            return count
        endmethod
        method operator first takes nothing returns integer
            return .peek()
        endmethod
        method operator random takes nothing returns integer
            local integer r=GetRandomInt(1,.size)
            // Get the first index of the list.
            local integer i=.top
            // Loop through the list.
            loop
                // Stop the loop after a random amount of repeats.
                set r=r-1
                exitwhen r==0 or i==0
                // Get the next index of the list.
                set i=Stack.next[i]
            endloop
            return Stack.value[i]
        endmethod
        method remove takes integer value returns boolean
            // Get the first index of the list.
            local integer i1=.top
            local integer i2
            // Check if the first index holds the value.
            if Stack.value[i1]==value then
                call .pop()
                return true
            endif
            // Search through the rest of the list.
            loop
                set i2=Stack.next[i1]
                // Stop the search when the end of the list is reached.
                exitwhen i2==0
                // Check if the next index holds the value.
                if Stack.value[i2]==value then
                    // Remove the index from the stack.
                    set Stack.next[i1]=Stack.next[i2]
                    // Add the removed index to the list of free indexes.
                    set Stack.next[i2]=Stack.free
                    set Stack.free=i2
                    set .size=.size-1
                    return true
                endif
                set i1=i2
            endloop
            return false
        endmethod
        method purge takes integer value returns integer
            local integer count=0
            local integer i1
            local integer i2
            // If the first index holds the value, pop it.
            loop
                // If the list is empty, return.
                if .top==0 then
                    return count
                endif
                // Repeat until the first index doesn't hold the value.
                exitwhen Stack.value[.top]!=value
                call .pop()
                set count=count+1
            endloop
            // Get the first index of the list.
            set i1=.top
            // Search through the rest of the list.
            loop
                set i2=Stack.next[i1]
                // Stop the search when the end of the list is reached.
                exitwhen i2==0
                // Check if the next index holds the value.
                if Stack.value[i2]==value then
                    // Remove the index from the stack.
                    set Stack.next[i1]=Stack.next[i2]
                    // Add the removed index to the list of free indexes.
                    set Stack.next[i2]=Stack.free
                    set Stack.free=i2
                    set .size=.size-1
                    set count=count+1
                else
                    set i1=i2
                endif
            endloop
            return count
        endmethod
        method enum takes Enum f, boolean top2bottom returns nothing
            local integer array value
            // Get the first index of the list.
            local integer i1=.top
            local integer i2=0
            // Populate the array.
            loop
                exitwhen i1==0
                set value[i2]=Stack.value[i1]
                set i2=i2+1
                set i1=Stack.next[i1]
            endloop
            // Call the Enum function for each value in the array.
            set i1=i2-1
            loop
                exitwhen i2==0
                set i2=i2-1
                // Enumerate in which direction?
                if top2bottom then
                    call f.evaluate(value[i1-i2])
                else
                    call f.evaluate(value[i2])
                endif
            endloop
        endmethod
        method copy takes nothing returns Stack
            local Stack that=Stack.create()
            // Get the first index of the list.
            local integer i1=.top
            local integer i2
            // Add a dummy index to the top of the new list.
            call that.push(0)
            set i2=that.top
            loop
                exitwhen i1==0
                // Get an index from the list of free indexes and add it at the end of the list.
                set Stack.next[i2]=Stack.free
                set i2=Stack.next[i2]
                set Stack.free=Stack.next[i2]
                // Extend the list of free indexes if needed.
                if Stack.free==0 then
                    set Stack.free=i2+1
                endif
                // Copy the value to the new index.
                set Stack.value[i2]=Stack.value[i1]
                set i1=Stack.next[i1]
            endloop
            // End the new list correctly.
            set Stack.next[i2]=0
            // Remove the dummy index.
            call that.pop()
            // Copy the size value to the new list.
            set that.size=this.size
            return that
        endmethod


        method onDestroy takes nothing returns nothing
            local integer n
            // Remove all remaining indexes from the stack.
            loop
                // Get the top index.
                set n=.top
                exitwhen n==0
                // Remove it from the stack.
                set .top=Stack.next[n]
                // Add it to the list of free indexes.
                set Stack.next[n]=Stack.free
                set Stack.free=n
            endloop
        endmethod
        static method onInit takes nothing returns nothing
            // Store the EMPTY value to index 0 to make .peek inline friendly.
            set Stack.value[0]=Stack.EMPTY
        endmethod
    endstruct
endlibrary
