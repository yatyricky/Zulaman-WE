//! zinc
library IntegerPool {
//==============================================================================
//  struct IntegerPool {
//      integer size;
//
//      method locate(integer num) -> integer
//      method add(integer num, integer weight) // update
//      method remove(integer num)
//      method get() -> integer
//  }
//==============================================================================
#define MAX_INT_POOL_SIZE 64
    public struct IntegerPool {
        private integer sum;
        private integer nums[MAX_INT_POOL_SIZE];
        private integer weights[MAX_INT_POOL_SIZE];
        integer size;
        
        method locate(integer num) -> integer {
            integer i = 0;
            while (i < this.size) {
                if (this.nums[i] == num) {
                    return i;
                }
                i += 1;
            }
            return -1;
        }
    
        method add(integer num, integer weight) {
            integer index = this.locate(num);
            if (index == -1) {
                this.nums[this.size] = num;
                this.weights[this.size] = weight;
                this.size += 1;
                this.sum += weight;
            } else {
                this.sum = this.sum - this.weights[index] + weight;
                this.weights[index] = weight;
            }
        }
        
        method remove(integer num) {
            integer index = this.locate(num);
            if (index != -1) {
                this.size -= 1;
                this.sum -= this.weights[index];                
                this.nums[index] = this.nums[this.size];
                this.weights[index] = this.weights[this.size];
            }
        }
        
        method get() -> integer {
            integer rnd;
            integer subsum;
            integer i;
            if (this.sum == 0) {
            //BJDebugMsg("NULL POOL");
                return 0;
            } else {
                rnd = GetRandomInt(0, this.sum - 1);
                subsum = 0;
                i = 0;
                while (i < this.size) {
                    subsum += this.weights[i];
                    if (rnd < subsum) {
                        return this.nums[i];
                    }
                    i += 1;
                }
            }
            BJDebugMsg(SCOPE_PREFIX + "|cffff0000FATAL ERROR:|r - pool failed" + ", rnd=" + I2S(rnd) + ", subsum=" + I2S(subsum) + ", sum=" + I2S(this.sum));
            return 0;
        }
        
        static method create() -> thistype {
            thistype this = thistype.allocate();
            this.sum = 0;
            this.size = 0;
            if (integer(this) > 127) {
                BJDebugMsg(SCOPE_PREFIX + "|cffff0000FATAL ERROR:|r - Number of max pools reached!");
            }
            return this;
        }
    }
#undef MAX_INT_POOL_SIZE
}
//! endzinc
