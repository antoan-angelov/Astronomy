package com.entry.astronomy.wrappers {
	
	/**
	 * Sydyrja nujnata informaciq za urok
	 * @author Antoan Angelov
	 */
	public class LessonWrapper {
		
		private var mId:String;
		private var mTitle:String;
		private var mContent:String;
		private var mImages:Vector.<ImageWrapper>;
		private var mTestWrapper:TestWrapper;
		
		public function LessonWrapper(id:String, title:String, content:String, images:Vector.<ImageWrapper>, testWrapper:TestWrapper) {
			this.mId = id;
			this.mTitle = title;
			this.mContent = "<span class=\"default\">"+content+"</span>";
			this.mImages = images;
			this.mTestWrapper = testWrapper;
		}
		
		public function getId():String {
			return mId;
		}
		
		public function getTitle():String {
			return mTitle;
		}
		
		public function getContent():String {
			return mContent;
		}
		
		public function getImages():Vector.<ImageWrapper> {
			return mImages;
		}
		
		public function getQuestions():Vector.<QuestionWrapper> {
			return mTestWrapper.getQuestions();
		}
		
		public function toString():String {
			return "[Lesson id="+mId+" title="+mTitle+" content="+mContent+"]";
		}
	}
}
