//! zinc
library Math {
	public function MathCeil(real r) -> integer {
		integer i = R2I(r);
		if (I2R(i) == r) {
			return i;
		} else {
			return i + 1;
		}
	}

	public function MathFloor(real r) -> integer {
		return R2I(r);
	}
}
//! endzinc
