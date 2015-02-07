//! zinc
library Math {
	public struct Circle {
		public real x, y, r;

		method destroy() {
			this.deallocate();
		}

		static method create() -> thistype {
			thistype this = thistype.allocate();
			this.x = 0.0;
			this.y = 0.0;
			this.r = 1.0;
			return this;
		}
	}

	public struct Point {
		public real x, y;

		method destroy() {
			this.deallocate();
		}

		static method create() -> thistype {
			thistype this = thistype.allocate();
			this.x = 0.0;
			this.y = 0.0;
			return this;
		}
	}

	public function IsPointInCircle(Point p, Circle c) -> boolean {
		return false;
	}

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
