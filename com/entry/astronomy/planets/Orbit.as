package com.entry.astronomy.planets {
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.SegmentSet;
	import away3d.primitives.LineSegment;
	
	import com.entry.astronomy.utils.MathUtils;
	import com.entry.astronomy.parser.XmlParser;
	
	import flash.geom.Vector3D;
	
	/**
	 * Vizualna interpretaciq na orbitata na kosmichesko tqlo
	 * @author Antoan Angelov
	 */
	public class Orbit extends ObjectContainer3D {
		
		private var mCosmicBody:CosmicBody3D;
		private var mCenterBody:ObjectContainer3D;
		private var mColor:Number;
		private var mSpeedCoeff:Number;
		private var mTrueAnomaly:Number;
		private var mInc:Number;
		private var mAp:Number;
		private var mLan:Number;
		private var mMaj:Number;
		private var mMin:Number;		
		
		private var mFoci:Number;
		private var v:Vector3D;
		
		public function Orbit(cosmicBody:CosmicBody3D, centerBody:ObjectContainer3D, color:uint, speedCoeff:Number, initialAngle:Number, 
				inclination:Number, argumentOfPeriapsis:Number, longitudeOfAscendingNode:Number, semiMinorAxis:Number, semiMajorAxis:Number) {
			
			this.mCosmicBody = cosmicBody;
			this.mCenterBody = centerBody;
			this.mColor = color;
			this.mSpeedCoeff = speedCoeff;
			this.mTrueAnomaly = initialAngle;
			this.mInc = inclination;
			this.mAp = argumentOfPeriapsis;
			this.mLan = longitudeOfAscendingNode;
			this.mMaj = semiMajorAxis;
			this.mMin = semiMinorAxis;			
		}
		
		public function init():void {
			v = new Vector3D();	
			
			// chertae triizmerna elipsa, koqto predstavlqva orbitata
			build(mCosmicBody, mCenterBody.position, 5, 1, mColor);
			
			// zavyrtame grafikata, za da syotvetstva zavyrtaneto i na zadadenite ygli v XML-skiq fail
			yaw(-mLan-90);
			pitch(mInc);
			yaw(-mAp+90);
			
			mTrueAnomaly = MathUtils.normalize(mTrueAnomaly);
			
			placeBodyAtAngle(mTrueAnomaly);
			
			mCosmicBody.setOrbit(this);
		}
		
		/**
		 * Dvijim kosmicheskoto tqlo po orbita
		 */
		public function moveAlongOrbit():void {
			placeBodyAtAngle(mTrueAnomaly);		
		}
		
		/**
		 * Postavq kosmicheskoto tqlo pod daden ygyl sprqmo orbitata
		 * @param angle
		 */
		public function placeBodyAtAngle(angle:Number):void {
			
			var rad:Number = mTrueAnomaly*Math.PI/180;
			
			v.setTo(mMin*Math.sin(rad), 0, -mMaj*Math.cos(rad)+mFoci);			
			
			var s:Number = 20000*mSpeedCoeff, d:Number = v.x*v.x+v.z*v.z;
			var arctan:Number = Math.atan(2*s/d);
			
			mTrueAnomaly = MathUtils.normalize(mTrueAnomaly, arctan*180/Math.PI);
			
			v = transform.transformVector(v);
			
			mCosmicBody.x = v.x;
			mCosmicBody.y = v.y;
			mCosmicBody.z = v.z;	
		}
		
		/**
		 * Chertae triizmerna elipsa, koqto predstavlqva orbitata
		 * @param cont
		 * @param center
		 * @param step
		 * @param thickness
		 * @param color
		 */
		private function build(cont:ObjectContainer3D, center:Vector3D, step:Number = 5, thickness:Number = 1, color = 0xFFFFFF):void {
			
			var set:SegmentSet = new SegmentSet();
			var v2:Vector3D = new Vector3D();			
			mFoci = Math.sqrt(mMaj*mMaj-mMin*mMin);

			var radInDeg:Number = Math.PI/180;
			v.setTo(mMin, 0, mFoci);
			
			for(var i:int = step; i<360; i += step) {
				var rad:Number = i*radInDeg;
				v2.setTo(mMin*Math.cos(rad), 0, mFoci+mMaj*Math.sin(rad));
				set.addSegment(new LineSegment(v, v2, color, color, thickness));
				v.copyFrom(v2);
			}
			
			v2.setTo(mMin, 0, mFoci);
			set.addSegment(new LineSegment(v, v2, color, color, thickness));
			set.name = "orbitSet";
			
			addChild(set);
		}
		
		public function getCenterBody():ObjectContainer3D {
			return mCenterBody;
		}
		
		public override function toString():String {
			return mCosmicBody + " > [" + XmlParser.TAG_ORBIT + " " + XmlParser.ATTRIBUTE_SPEED_COEFF + "=" + mSpeedCoeff + ", "
				+ XmlParser.ATTRIBUTE_TRUE_ANOMALY + "=" + mTrueAnomaly + ", " + XmlParser.ATTRIBUTE_INCLINATION + "=" + mInc + ", " 
				+ XmlParser.ATTRIBUTE_ARGUMENT_OF_PERIAPSIS + "=" + mAp + ", " + XmlParser.ATTRIBUTE_LONGITUDE_OF_ASCENDING_NODE + "=" 
				+ mLan + ", " + XmlParser.ATTRIBUTE_SEMI_MINOR_AXIS + "=" + mMin + ", "	+ XmlParser.ATTRIBUTE_SEMI_MAJOR_AXIS + "=" 
				+ mMaj + "]";
		}
	}
}
