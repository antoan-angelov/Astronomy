package com.entry.astronomy.lessons {
	import com.entry.astronomy.Main;
	import com.entry.astronomy.utils.MathUtils;
	import com.entry.astronomy.wrappers.AnswerWrapper;
	import com.entry.astronomy.wrappers.LessonWrapper;
	import com.entry.astronomy.wrappers.QuestionWrapper;
	
	import fl.controls.RadioButton;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Utils3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Sydyrja metodi i informaciq za testovete kym urocite
	 * @author Antoan Angelov
	 */
	public class Test {
		
		private var mContext:Main;
		private var mTestCont:Sprite;
		private var mCurrentLessonWrapper:LessonWrapper;
		private var questionIds:Array;
		
		public function Test(context:Main, testCont:Sprite) {
			this.mContext = context;
			this.mTestCont = testCont;
		}
		
		/**
		 * Inicializira vizualnata interpretaciq na testa i dobavq vsichki vyprosi kym nego. 
		 * @param lessonWrapper Info za uroka
		 */
		public function init(lessonWrapper:LessonWrapper):void {
			
			this.mCurrentLessonWrapper = lessonWrapper;
			
			var test:MovieClip = mContext.getChildByName("test") as MovieClip;
			var questions:Vector.<QuestionWrapper> = mCurrentLessonWrapper.getQuestions();
			var tempQuestionIds:Array = [];
			questionIds = []
			
			// razmestva vyprosite da sa v proizvolen red
			for(var i:int = 0; i<questions.length; i++)
				tempQuestionIds[i] = i;
			
			for(i = 0; i<questions.length; i++) {
				var rand:int = MathUtils.getRandom(tempQuestionIds.length-1);
				questionIds[i] = tempQuestionIds[rand];
				MathUtils.removeElement(tempQuestionIds, rand);
			}
			
			tempQuestionIds = null;
			
			mTestCont.removeChildren();
			test.addChild(mTestCont);
			var px:Number = -40, py:Number = -260;
			
			// dobavqt se vsichki vyprosi, otgore nadolu
			for(var j:int = 0; j<questions.length; j++) {
				var q:Question = new Question();
				var questionWrapper:QuestionWrapper = questions[questionIds[j]];
				var title:TextField = q.getChildByName("title") as TextField;
				title.embedFonts = true;
				title.text = questionWrapper.getValue();
				var answers:Vector.<AnswerWrapper> = questionWrapper.getAnswers();
				
				if(answers.length == 2)
					q.getChildByName("r3").visible = false;
				
				var groupName:String = "group"+(j+1);
				var rb:RadioButton = q.getChildByName("r1") as RadioButton;
				rb.label = answers[0].getValue();
				rb.groupName = groupName;
				rb = q.getChildByName("r2") as RadioButton;
				rb.label = answers[1].getValue();
				rb.groupName = groupName;
				if(answers.length == 3) {
					rb = q.getChildByName("r3") as RadioButton;
					rb.label = answers[2].getValue();
					rb.groupName = groupName;
				}
				q.x = px;
				q.y = py;
				py += 60;
				mTestCont.addChild(q);
			}
		}
		
		/**
		 * Proverka na testa - proverqva vseki daden otgovor i izpisva kolko sa vernite otgovori.
		 */
		public function check():void {
			var mNumCorrectAnswers:int = 0;
			var questions:Vector.<QuestionWrapper> = mCurrentLessonWrapper.getQuestions();
			
			// obhojda vseki vypros i proverqva dadeniq za nego otgovor
			for(var j:int=0; j<mTestCont.numChildren; j++) {					
				var question:Question = mTestCont.getChildAt(j) as Question;
				var r1:RadioButton = question.getChildByName("r1") as RadioButton;
				var sd:int = int(r1.group.selectedData);
				var sel:int = sd-1;
				var questionWrapper:QuestionWrapper = questions[questionIds[j]];
				var corr:int = questionWrapper.getCorrectIndex()+1;
				var r2:RadioButton = question.getChildByName("r"+corr) as RadioButton;
				r2.textField.textColor = 0x19B819;
				
				if(sel == -1)
					continue;
				
				var answers:Vector.<AnswerWrapper> = questionWrapper.getAnswers();
				if(answers[sel].isCorrect()) {
					mNumCorrectAnswers++;
				}
				else {
					var r:RadioButton = question.getChildByName("r"+sd) as RadioButton;
					r.textField.textColor = 0xFF0000;
				}
			}
			
			var test:MovieClip = mContext.getChildByName("test") as MovieClip;
			var correctTf:TextField = test.getChildByName("tf_correct") as TextField;
			correctTf.textColor = (mNumCorrectAnswers > questions.length*0.5 ? 0x00FF00 : 0xFF0000);
			correctTf.text = "Верни отговори: "+mNumCorrectAnswers+" от "+questions.length;
		}
	}
}
