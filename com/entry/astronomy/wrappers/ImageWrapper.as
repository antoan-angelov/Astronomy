package com.entry.astronomy.wrappers {
	
	/**
	 * Sydyrja nujnata informaciq za snimka kym urok
	 * @author Antoan Angelov
	 */
	public class ImageWrapper {
		
		private var mSrc:String;
		private var mDescr:String;
		
		public function ImageWrapper(src:String, descr:String) {
			this.mSrc = src;
			this.mDescr = descr;
		}
		
		public function getSrc():String {
			return mSrc;
		}
		
		public function getDescr():String {
			return mDescr;
		}
	}
}
