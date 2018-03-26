//! zinc
library DataStructure {
    
    //! textmacro WriteArrayList takes ClassName, Type, NULL
    public struct $ClassName$ {
        private static $Type$ elem[];
        private static integer theSize = 0;
        
        static method size() -> integer {
            return thistype.theSize;
        }
        
        static method locate($Type$ elem) -> integer {
            integer i = 0;
            integer index = -1;
            while (i < thistype.theSize && index == -1) {
                if (elem == thistype.elem[i]) {
                    index = i;
                }
                i += 1;
            }
            return index;
        }
        
        static method get(integer index) -> $Type$ {
            if (index < 0 || index >= thistype.theSize) {
                debug BJDebugMsg("|cffff0000thistype, Index out of bounds|r");
                return $NULL$;
            }
            return thistype.elem[index];
        }
        
        static method add($Type$ elem) -> boolean {
            if (elem == $NULL$) {
                debug BJDebugMsg("|cffff0000thistype, Null pointer error|r");
                return false;
            }
            if (thistype.locate(elem) != -1) {
                debug BJDebugMsg("Elem already exists in thistype");
                return false;
            }
            thistype.elem[thistype.theSize] = elem;
            thistype.theSize += 1;
            return true;
        }
        
        static method remove($Type$ elem) -> boolean {
            integer index = 0;
            if (elem == $NULL$) {
                debug BJDebugMsg("|cffff0000thistype, Null pointer error|r");
                return false;
            }
            index = thistype.locate(elem);
            if (index == -1) {
                debug BJDebugMsg("Elem does not exist in thistype");
                return false;
            }
            thistype.theSize -= 1;
            thistype.elem[index] = thistype.elem[thistype.theSize];
            thistype.elem[thistype.theSize] = $NULL$;
            return true;
        }

        static method pop() -> $Type$ {
            $Type$ ret;
            if (thistype.theSize <= 0) {
                debug BJDebugMsg("thistype: array size = 0");
                return $NULL$;
            }
            thistype.theSize -= 1;
            ret = thistype.elem[thistype.theSize];
            thistype.elem[thistype.theSize] = $NULL$;
            return ret;
        }
        
        static method push($Type$ elem) {
            thistype.elem[thistype.theSize] = elem;
            thistype.theSize += 1;
        }
    }
    //! endtextmacro   
    
    //! textmacro WriteQueueList takes Type, NULL
    private struct QueueNode_$Type$ {
        $Type$ elem;
        thistype prev;
        thistype next;
        
        static static method create($Type$ elem) -> thistype {
            thistype this = thistype.allocate();
            this.elem = elem;
            return this;
        }
        
        static method destroy() {
            this.elem = $NULL$;
            this.prev = 0;
            this.next = 0;
            this.deallocate();
        }
    }
    
    public struct QueueList_$Type$ {
        private QueueNode_$Type$ front;
        private QueueNode_$Type$ rear;
        
        static method isEmpty() -> boolean {
            return (this.front == 0);
        }
        
        static method getLength() -> integer {
            QueueNode_$Type$ index = this.front;
            integer size = 0;
            while (index != 0) {
                index = index.next;
                size += 1;
            }
            return size;
        }
        
        static method in($Type$ elem) {
            QueueNode_$Type$ newItem = 0;
            if (elem == $NULL$) {
                debug BJDebugMsg("|cffff0000thistype, Null pointer error|r");
                return;
            }
            newItem = QueueNode_$Type$.create(elem);
            newItem.next = 0;
            if (this.isEmpty()) {
                this.front = newItem;
                this.front.prev = 0;
                this.rear = this.front;
            } else {
                newItem.prev = this.rear;
                this.rear.next = newItem;
                this.rear = newItem;
            }
        }
        
        static method out() -> $Type$ {
            $Type$ ret = $NULL$;
            QueueNode_$Type$ tmp = 0;
            if (this.isEmpty()) {
                debug BJDebugMsg("|cffff0000thistype, attempt to remove element from empty queue|r");
                return $NULL$;
            }
            ret = this.front.elem;
            tmp = this.front;
            if (this.getLength() == 1) {
                this.rear = 0;
            }
            this.front = this.front.next;
            tmp.destroy();
            if (this.front != 0) {
                this.front.prev = 0;
            }
            return ret;
        }
        
        static static method create() -> thistype {
            thistype this = thistype.allocate();
            this.front = 0;
            this.rear = 0;
            return this;
        }
        
        static method destroy() {
            QueueNode_$Type$ index = this.front;
            while (index != 0) {
                index = index.next;
                this.out();
            }
            this.deallocate();
        }
    }
    //! endtextmacro   
    
}
//! endzinc
