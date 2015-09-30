//! zinc
library Math requires Vector {
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

		static method new(real x, real y) -> thistype {
			thistype this = thistype.allocate();
			this.x = x;
			this.y = y;
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

	public function DistancePointAndLineSegment(vector a, vector b, vector p) -> real {
		vector pa = vector.difference(a, p);
		vector ba = vector.difference(a, b);
		vector ab = vector.difference(b, a);
		vector pb = vector.difference(b, p);
		real pab = vector.getAngle(pa, ba);
		real pba = vector.getAngle(pb, ab);
		real dis;
		// print("pa="+pa.toString());
		// print("ba="+ba.toString());
		// print("ab="+ab.toString());
		// print("pb="+pb.toString());
		// print("pab="+R2S(pab));
		// print("pba="+R2S(pba));
		if (pab > bj_PI * 0.5) {
			dis = pa.getLength();
			pa.destroy();
			pb.destroy();
			ab.destroy();
			ba.destroy();
		} else if (pab > bj_PI * 0.5) {
			dis = pb.getLength();
			pa.destroy();
			pb.destroy();
			ab.destroy();
			ba.destroy();
		} else {
			pa.x = 0 - pa.x;
			pa.y = 0 - pa.y;
			pa.z = 0 - pa.z;
			dis = RAbsBJ(ab.y * pa.x - ab.x * pa.y) / ab.getLength();
			pa.destroy();
			pb.destroy();
			ab.destroy();
			ba.destroy();
		}
		return dis;
	}
}
//! endzinc
