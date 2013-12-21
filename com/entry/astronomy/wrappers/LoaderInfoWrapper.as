package com.entry.astronomy.wrappers {
	import away3d.entities.Mesh;
	
	import com.entry.astronomy.planets.CosmicBody3D;
	
	/**
	 * Sydyrja nujnata informaciq za zarejdane na vizualen material za kosmicheskite obekti
	 * @author Antoan Angelov
	 */
	public class LoaderInfoWrapper {
		
		public var cosmicBody:CosmicBody3D;
		public var mesh:Mesh;
		public var flags:int;
		
		public var map:String;
		public var normalMap:String;
		public var ringMap:String;
		
		public var isMapLoaded:Boolean;
		public var isNormalMapLoaded:Boolean;
		public var isRingMapLoaded:Boolean;
		
		public function LoaderInfoWrapper() {
		}
	}
}
