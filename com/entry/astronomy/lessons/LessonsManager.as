package com.entry.astronomy.lessons {
	import com.entry.astronomy.wrappers.LessonWrapper;
	
	/**
	 * Ulesnqva namiraneto na konkreten urok
	 * @author Antoan Angelov
	 */
	public class LessonsManager {
		
		private var mLessons:Array;
		
		public function LessonsManager(lessons:Array) {
			this.mLessons = lessons;
		}
		
		/**
		 * Vryshta instanciq na LessonWrapper spored id-to na uroka
		 * @param id Id na uroka
		 * @return Uroka
		 */
		public function getLessonById(id:String):LessonWrapper {
			for(var i:int=0; i<mLessons.length; i++) {
				var lesson:LessonWrapper = mLessons[i] as LessonWrapper;
				if(lesson.getId() == id)
					return lesson;
			}
			
			return null;
		}
		
		/**
		 * Vryshta instanciq na LessonWrapper spored zaglavieto na uroka
		 * @param title Zaglavie na uroka
		 * @return Uroka
		 */
		public function getLessonByTitle(title:String):LessonWrapper {
			for(var i:int=0; i<mLessons.length; i++) {
				var lesson:LessonWrapper = mLessons[i] as LessonWrapper;
				if(lesson.getTitle() == title)
					return lesson;
			}
			
			return null;
		}
		
		/**
		 * @return Vsichki uroci
		 */
		public function getLessons():Array {
			return mLessons;
		}
	}
}
