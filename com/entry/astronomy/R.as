package com.entry.astronomy {
	
	import away3d.materials.MaterialBase;
	import away3d.textures.BitmapTexture;
		
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * Sydyrja globalni konstanti.
	 * @author Antoan Angelov
	 */
	public class R {
		
		/** Dali e v DEBUG rejim */
		public static const DEBUG_MODE:Boolean = false;
		/** Koeficient, koito se otnasq za dyljinata na otdelnite koordinatni osi za otdelnite planeti (X, Y, Z) */
		public static const DEBUG_AXIS_FACTOR:Number = 1.25;
		
		/** Direktoriq s teksturite */
		public static const TEXTURES_DIR:String = "assets/img/textures/";
		/** Direktoriq s kartinkite za urocite */
		public static const LESSONS_IMAGES_DIR:String = "assets/img/lessons/";
		/** Direktoriq s lessons.xml */
		public static const LESSONS_LOCATION:String = "assets/xml/lessons.xml";
		/** Direktoriq s description.xml */
		public static const DESCRIPTOR_LOCATION:String = "assets/xml/description.xml";
		/** Direktoriq s CSS stilovete */
		public static const CSS_LOCATION:String = "assets/css/main.css";
		
		/** Naklona na Zemqta */
		public static const TILT_EARTH:Number = 23.5;
		
		public function R() {
		}
	}
}
