package com.entry.astronomy.wrappers {
	
	/**
	 * Sydyrja neobhodimata informaciq za vypros kym test
	 * @author Antoan Angelov
	 */
	public class QuestionWrapper {
		
		private var mValue:String;
		private var mAnswers:Vector.<AnswerWrapper>;
		private var mCorrectIndex:int;
		
		public function QuestionWrapper(value:String, answers:Vector.<AnswerWrapper>) {
			mValue = value;
			mAnswers = answers;
			
			for(var i:int = 0; i<mAnswers.length; i++) {
				if(mAnswers[i].isCorrect()) {
					mCorrectIndex = i;
					break;
				}
			}
		}
		
		public function getValue():String {
			return mValue;
		}
		
		public function getAnswers():Vector.<AnswerWrapper> {
			return mAnswers;	
		}
		
		public function getCorrectIndex():int {
			return mCorrectIndex;
		}
	}
}
