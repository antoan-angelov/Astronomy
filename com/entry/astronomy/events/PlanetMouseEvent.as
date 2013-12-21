package com.entry.astronomy.events {
	
	import com.entry.astronomy.planets.CosmicBodyBase;
	
	import flash.events.Event;
	
	/**
	 * Sydyrja sybitiq na mishka sprqmo planetite - CLICK, DOWN, UP, OVER, OUT.
	 * @author Antoan Angelov
	 */
	public class PlanetMouseEvent extends Event {
		
		/** Cykane na mishkata nad planeta */
		public static const CLICK:String = "planet_click";
		/** Natiskane na mishkata nad planeta */
		public static const DOWN:String = "planet_down";
		/** Otpuskane na mishkata nad planeta */
		public static const UP:String = "planet_up";
		/** Minavane na mishkata nad planeta */
		public static const OVER:String = "planet_over";
		/** Izlizane na mishkata ot planeta */
		public static const OUT:String = "planet_out";
		
		public var planet:CosmicBodyBase;
		
		public function PlanetMouseEvent(type:String, planet:CosmicBodyBase) {
			super(type, true);
			
			this.planet = planet;
		}
	}
}
