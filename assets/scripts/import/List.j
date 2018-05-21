//! zinc
library List requires DebugExporter {

    integer nNodes = 0;

    // a and b are objects, returns integer
    public type ListSorter extends function(integer, integer) -> integer;

    struct NodeObject {
        integer data;
        thistype next;
        thistype prev;

        method destroy() {
            this.deallocate();
            nNodes -= 1;
        }

        static method create(integer data) -> thistype {
            thistype new = thistype.allocate();
            nNodes += 1;
            new.data = data;
            new.next = 0;
            new.prev = 0;
            return new;
        }
    }

    public struct ListObject {
        private integer n;
        NodeObject head;
        NodeObject tail;

        method prettyPrint() {
            NodeObject it;
            print("- - - - - - - - - - - -");
            print("ListObject[" + I2S(this) + "] length[" + I2S(this.count()) + "]");
            print("head["+I2S(this.head)+"] tail["+I2S(this.tail)+"]");
            it = this.head;
            while (it != 0) {
                print("["+I2S(it)+"].data("+I2S(it.data)+").prev["+I2S(it.prev)+"].next["+I2S(it.next)+"]");
                it = it.next;
            }
            print("Nodes = " + I2S(nNodes));
            print("- - - - - - - - - - - -");
        }

        method empty() {
            NodeObject it = this.head;
            NodeObject tmp;
            while (it != 0) {
                tmp = it.next;
                it.destroy();
                it = tmp;
            }
            this.head = 0;
            this.tail = 0;
            this.n = 0;
        }

        method destroy() {
            this.empty();
            this.deallocate();
        }

        method sort(ListSorter sorter) {

        }

        method count() -> integer {
            return this.n;
        }

        method nodeAt(integer i) -> NodeObject {
            integer c = 0;
            NodeObject it = this.head;
            while (c < i && it != 0) {
                it = it.next;
                c += 1;
            }
            if (it != 0) {
                return it;
            } else {
                loge("List index out of bounds, n = " + I2S(this.n) + " i = " + I2S(i));
                return 0;
            }
        }

        method objectAt(integer i) -> integer {
            NodeObject it = this.nodeAt(i);
            if (it != 0) {
                return it.data;
            } else {
                return 0;
            }
        }

        method indexOfObject(integer obj) -> integer {
            NodeObject it = this.head;
            integer c = 0;
            boolean found = false;
            while (found == false && it != 0) {
                if (it.data == obj) {
                    found = true;
                } else {
                    c += 1;
                    it = it.next;
                }
            }
            if (found == true) {
                return c;
            } else {
                return -1;
            }
        }

        method removeNode(NodeObject node) -> integer {
            integer ret = node.data;
            this.n -= 1;
            if (node != this.head && node != this.tail) {
                node.prev.next = node.next;
                node.next.prev = node.prev;
            }
            if (node == this.head) {
                this.head = node.next;
                if (this.head != 0) {
                    this.head.prev = 0;
                }
            }
            if (node == this.tail) {
                this.tail = node.prev;
                if (this.tail != 0) {
                    this.tail.next = 0;
                }
            }
            node.destroy();
            return ret;
        }

        method removeAt(integer i) -> integer {
            NodeObject it = this.nodeAt(i);
            integer obj;
            if (it != 0) {
                obj = it.data;
                this.removeNode(it);
                return obj;
            } else {
                return 0;
            }
        }

        method remove(integer obj) {
            NodeObject it = this.head;
            boolean found = false;
            while (found == false && it != 0) {
                if (it.data == obj) {
                    found = true;
                } else {
                    it = it.next;
                }
            }
            if (found == true) {
                this.removeNode(it);
            } else {
                loge("List does not contain " + I2S(obj));
            }
        }

        method pop() -> integer {
            if (this.n == 0) {
                return 0;
            } else {
                return this.removeNode(this.tail);
            }
        }

        method push(integer obj) {
            NodeObject new = NodeObject.create(obj);
            new.data = obj;
            new.next = 0;
            this.n += 1;
            if (this.head == 0) {
                this.head = new;
                this.tail = new;
            } else {
                new.prev = this.tail;
                this.tail.next = new;
                this.tail = new;
            }
        }

        static method create() -> thistype {
            thistype this = thistype.allocate();
            this.n = 0;
            this.head = 0;
            this.tail = 0;
            return this;
        }
    }

}
//! endzinc
