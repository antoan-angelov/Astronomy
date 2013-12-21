package com.entry.astronomy.wrappers {
	
	/**
	 * Sydyrja nujnata informaciq za otgovor na vypros ot test
	 * @author Antoan Angelov
	 */
	public class AnswerWrapper {
		
		private var mValue:String;
		private var mCorrect:Boolean;
		
		public function AnswerWrapper(value:String, correct:Boolean) {
			mValue = value;
			mCorrect = correct;
		}
		
		public function isCorrect():Boolean {
			return mCorrect;
		}
		
		public function getValue():String {
			return mValue;
		}
	}
}
