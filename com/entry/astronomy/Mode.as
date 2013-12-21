package com.entry.astronomy {
	
	/**
	 * Sydyrja razlichnite rejimi na programata, definirani chrez konstanti.
	 * Programata se dyrji po razlichen nachin za razlichnite rejimi.
	 * @author Antoan Angelov
	 */
	public class Mode {
		
		/** rejim zarejdane **/
		public static const MODE_LOADING:int = 1;
		/** rejim nachalen ekran, tuk e nachalnata animaciq **/
		public static const MODE_INTRO:int = 2;
		/** rejim svobodna navigaciq iz prostranstvoto **/
		public static const MODE_FIRST_PERSON:int = 3;
		/** rejim vyrtene na Slynchevata sistema okolo osta na Slynceto **/
		public static const MODE_ROTATE_SOLAR_SYSTEM:int = 4;
		/** rejim priblijavane kym planeta/zvezdno tqlo **/
		public static const MODE_PLANET_ZOOM_ANIMATION:int = 5;
		/** rejim otdalechavane ot planeta/zvezdno tqlo **/
		public static const MODE_PLANET_UNZOOM_ANIMATION:int = 6;
		/** rejim razglejdane na individualna planeta, predi da q zavyrtim rychno **/
		public static const MODE_VIEW_PLANET:int = 7;
		/** rejim razglejdane na individualna planeta, sled kato sme zapochnali da q vyrtim rychno **/
		public static const MODE_ROTATE_PLANET:int = 8;
		/** rejim natiskane s mishkata vyrhu planeta **/
		public static const MODE_PRESS_PLANET:int = 9;
		/** rejim chetene na urok **/
		public static const MODE_LESSON:int = 10;
		/** rejim pravene na test **/
		public static const MODE_TEST:int = 11;
		/** rejim razglejdane na resursite **/
		public static const MODE_VIEW_RESOURCES:int = 12;
		
		public function Mode() {
		}
	}
}
