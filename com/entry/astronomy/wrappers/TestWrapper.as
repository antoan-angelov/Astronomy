package com.entry.astronomy.wrappers {
	
	/**
	 * Sydyrja neobhodimata informaciq za test kym urok
	 * @author Antoan Angelov
	 */
	public class TestWrapper {
		
		private var mQuestions:Vector.<QuestionWrapper>;
		
		public function TestWrapper(questions:Vector.<QuestionWrapper>) {
			this.mQuestions = questions;
		}
		
		public function getQuestions():Vector.<QuestionWrapper> {
			return mQuestions;
		}
	}
}
