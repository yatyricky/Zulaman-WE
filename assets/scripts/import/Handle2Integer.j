//! zinc
library Handle2Integer {
    constant integer MAX_INSTANCES = 32767;

    //! textmacro WriteHandle2Int takes TYPE, FTYPE
    $TYPE$ $TYPE$objs[];
    integer $TYPE$table[];
    integer $TYPE$freed = 0;
    integer $TYPE$count = 0;

    public function $FTYPE$2Int($TYPE$ u) -> integer {
        integer ref = $TYPE$freed;
        if (ref != 0) {
            $TYPE$freed = $TYPE$table[ref];
        } else {
            $TYPE$count += 1;
            ref = $TYPE$count;
        }
        if (ref > MAX_INSTANCES) {
            return 0;
        }
        $TYPE$table[ref] = -1;
        $TYPE$objs[ref] = u;
        return ref;
    }

    public function Int2$FTYPE$(integer ref) -> $TYPE$ {
        if (ref == 0) {
            return null;
        } else if ($TYPE$table[ref] != -1) {
            return null;
        }
        $TYPE$table[ref] = $TYPE$freed;
        $TYPE$freed = ref;
        return $TYPE$objs[ref];
    }

    public function IntRef$FTYPE$(integer ref) -> $TYPE$ {
        if (ref == 0) {
            return null;
        } else if ($TYPE$table[ref] != -1) {
            return null;
        }
        return $TYPE$objs[ref];
    }
    //! endtextmacro

    //! runtextmacro WriteHandle2Int("unit", "Unit")
    //! runtextmacro WriteHandle2Int("effect", "Eff")

}
//! endzinc
