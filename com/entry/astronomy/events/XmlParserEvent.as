package com.entry.astronomy.events {
	
	import com.entry.astronomy.planets.CosmicBodyBase;
	
	import flash.events.Event;
	
	/**
	 * Sydyrja sybitiq, svyrzani s XML parsvaneto.
	 * @author Antoan Angelov
	 */
	public class XmlParserEvent extends Event {
		
		public static const XML_DESCRIPTION_LOADED:String = "xml_description_loaded";
		public static const XML_LESSONS_LOADED:String = "xml_lessons_loaded";
		
		public static const STATUS_OK:int = 1;
		public static const STATUS_MISSING_TAG:int = 2;
		public static const STATUS_MISSING_ATTRIBUTE:int = 3;
		
		public var status:int;
		public var array:Array;
		public var info:String;
		
		public function XmlParserEvent(type:String, status:int, array:Array, info:String = null) {
			super(type);
			
			this.info = info;
			this.array = array;
			this.status = status;
		}
	}
}
