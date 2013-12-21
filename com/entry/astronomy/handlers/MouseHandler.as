package com.entry.astronomy.handlers {
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	
	import caurina.transitions.Tweener;
	
	import com.entry.astronomy.Main;
	import com.entry.astronomy.Mode;
	import com.entry.astronomy.events.PlanetMouseEvent;
	import com.entry.astronomy.lessons.Lesson;
	import com.entry.astronomy.lessons.LessonsManager;
	import com.entry.astronomy.lessons.Test;
	import com.entry.astronomy.planets.CosmicBodyBase;
	import com.entry.astronomy.planets.Marker;
	import com.entry.astronomy.visuals.LeftGalleryArrow;
	import com.entry.astronomy.visuals.RightGalleryArrow;
	import com.entry.astronomy.visuals.buttons.CheckTestBtn;
	import com.entry.astronomy.visuals.buttons.CloseInfoBtn;
	import com.entry.astronomy.visuals.buttons.GoToLessonBtn;
	import com.entry.astronomy.visuals.buttons.GoToTestBtn;
	import com.entry.astronomy.visuals.buttons.LessonItemBtn;
	import com.entry.astronomy.visuals.buttons.OpenInfoBtn;
	import com.entry.astronomy.visuals.buttons.QuitBtn;
	import com.entry.astronomy.visuals.buttons.ResourcesBtn;
	import com.entry.astronomy.visuals.buttons.ReturnToSystemBtn;
	import com.entry.astronomy.visuals.buttons.ShowMenuBtn;
	import com.entry.astronomy.wrappers.LessonWrapper;
	
	import fl.containers.UILoader;
	import fl.controls.RadioButton;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.system.fscommand;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Tozi klas obrabotva sybitiqta s mishka.
	 */
	public class MouseHandler {
		
		private var mContext:Main;
		private var mView:View3D;
		private var mGalleryCont:Sprite;
		private var mTestCont:Sprite;
		private var mLessonsManager:LessonsManager;
		private var mCurrentLessonWrapper:LessonWrapper;
		private var mCurrentLesson:Lesson;
		private var mCurrentTest:Test;
		private var mCameraController:HoverController;
		private var mCss:StyleSheet;
		private var mLessons:Array;
		private var mTempPrevMode:int;
		
		public function MouseHandler(context:Main, view:View3D, galleryCont:Sprite, testCont:Sprite, lessonsManager:LessonsManager, 
			cameraController:HoverController, css:StyleSheet) {
			
			mContext = context;
			mView = view;
			mGalleryCont = galleryCont;
			mTestCont = testCont;
			mLessonsManager = lessonsManager;
			mCameraController = cameraController;
			mCss = css;
			
			mCurrentLesson = new Lesson(mContext, mGalleryCont);
			mCurrentTest = new Test(mContext, mTestCont);						
			mLessons = mLessonsManager.getLessons();
		}
		
		/**
		 * Izvikva se pri natiskane na leviq buton na mishkata. Tuk se "zakliuchva" dvijenieto na kamerata, v sluchai
		 * che natiskame element ot 2D interfeisa (buton, tekstovo pole i t.n.)
		 */
		public function mDown(event:MouseEvent):void {
			
			mContext.setIsMouseDown(true);
			// ako sme natisnali s mishkata vyrhu 2D element, zakliuchvame dvijenieto na kamerata
			var lock:Boolean = !mView.contains((event.target as DisplayObject));
			mContext.setLockRotation(lock);

			if (!lock && !mContext.isMode(Mode.MODE_PLANET_ZOOM_ANIMATION) && !mContext.isMode(Mode.MODE_PLANET_UNZOOM_ANIMATION)) {
				var currMouseOverPlanet:CosmicBodyBase = mContext.getCurrentMouseOverPlanet()
				if (!currMouseOverPlanet) {
					if (mContext.isMode(Mode.MODE_INTRO))
						mContext.setMode(Mode.MODE_ROTATE_SOLAR_SYSTEM);
					else if (mContext.isMode(Mode.MODE_VIEW_PLANET))
						mContext.setMode(Mode.MODE_ROTATE_PLANET);
				}
				else if(mContext.getCurrentPlanet() != currMouseOverPlanet){
					mContext.setMode(Mode.MODE_PRESS_PLANET);
				}
			}
		}
		
		/**
		 * Izvikva se pri puskane na leviq buton na mishkata. 
		 */
		public function mUp(event:MouseEvent):void {
			mContext.setIsMouseDown(false);
			
			if(mContext.isMode(Mode.MODE_PRESS_PLANET) && !mContext.getCurrentMouseOverPlanet()) {
				mContext.revertMode();				
				mContext.setLockRotation(false);
			}
		}
		
		/**
		 * Izvikva se pri minavane na mishkata nad koito i da e element ot scenata. Izpolzvame go, za da zasechem
		 * minavaneto na mishkata nad butona "Uroci" v nachalniq ekran.
		 */
		public function mOver(event:MouseEvent):void {
			if(mContext.currentFrameLabel == "main") {
				if(event.target is ShowMenuBtn) {				
					var py:Number = 39;
					var mainMenu:MovieClip = mContext.getChildByName("main_menu") as MovieClip;
					var lessonsMenuCont:MovieClip = mainMenu.getChildByName("lessons_menu_cont") as MovieClip;
					for(var i:int = 0; i<mLessons.length; i++) {
						var item:LessonItemBtn = new LessonItemBtn();
						var tf:TextField = item.getChildByName("tf") as TextField;
						var lesson:LessonWrapper = mLessons[i] as LessonWrapper;
						tf.text = lesson.getTitle();
						item.x = -0.5;
						item.y = py;
						py += 43;
						lessonsMenuCont.addChild(item);
					}
				}
			}
		}
		
		/**
		 * Izvikva se pri izlizane na mishkata ot koito i da e element ot scenata. Izpolzvame go, za da zasechem 
		 * izlizaneto na mishkata ot meniuto s urocite v nachalniq ekran.
		 */
		public function mOut(event:MouseEvent):void {
			if(mContext.currentFrameLabel == "main") {
				var mainMenu:MovieClip = mContext.getChildByName("main_menu") as MovieClip;
				var lessonsMenuCont:MovieClip = mainMenu.getChildByName("lessons_menu_cont") as MovieClip;
				if(!lessonsMenuCont.getBounds(mContext).contains(mContext.mouseX, mContext.mouseY)) {
					lessonsMenuCont.removeChildren(1);
				}
			}
		}
		
		/**
		 * Izvikva se pri zavyrtane na kolelceto na mishkata. Tuk priblijavame ili otdalechavame kamerata v zavisimost
		 * ot posokata na vyrtene na kolelceto.
		 */
		public function mWheel(event:MouseEvent):void {
			
			if (!mContext.isMode(Mode.MODE_PLANET_ZOOM_ANIMATION)) {
				mView.camera.moveForward(Main.SCROLL_CAMERA_SPEED * event.delta);
				mCameraController.distance -= Main.SCROLL_CAMERA_SPEED * event.delta;
				
				if (mContext.isMode(Mode.MODE_INTRO))
					mContext.setMode(Mode.MODE_ROTATE_SOLAR_SYSTEM);
				else if (mContext.isMode(Mode.MODE_VIEW_PLANET))
					mContext.setMode(Mode.MODE_ROTATE_PLANET);
			}
		}
		
		/**
		 * Izvikva se pri natiskane s mishka nqkyde po ekrana. Tuk proverqvame dali sa natisnati samo elementite, koito ni interesuvat.
		 */
		public function mClick(event:MouseEvent):void {
			
			if(event.target is GoToLessonBtn) {
				var currentPlanet:CosmicBodyBase = mContext.getCurrentPlanet();
				var lessonWrapper:LessonWrapper = mLessonsManager.getLessonById(currentPlanet.getId());
						
				gotoLesson(lessonWrapper, true);				
			}
			else if(event.target is CloseInfoBtn) {
				close();
			}
			else if(event.target is ReturnToSystemBtn) {
				returnToSystem();
			}
			else if(event.target is RightGalleryArrow) {
				mCurrentLesson.loadNextImages();
			}
			else if(event.target is LeftGalleryArrow) {
				mCurrentLesson.loadPrevImages();
			}
			// Kartinkite pri urocite sa instancii na UILoader, proverqvame za tqh
			else if(event.target is UILoader) {
				mCurrentLesson.viewImage(UILoader(event.target));
			}
			else if(event.target == mGalleryCont) {
				if(!Tweener.isTweening(mGalleryCont)) {
					Tweener.addTween(mGalleryCont, {alpha:0, time:0.7, 
						onComplete: function() {
							mGalleryCont.removeChildren();
							mGalleryCont.graphics.clear();
						}
					});
				}
			}
			else if(event.target is GoToTestBtn) {
				gotoTest();
			}
			else if(event.target is CheckTestBtn) {
				mCurrentTest.check();
			}
			else if(event.target is OpenInfoBtn) {
				openInfo();
			}
			else if(event.target is LessonItemBtn) {
				var item:LessonItemBtn = event.target as LessonItemBtn;
				var tf:TextField = item.getChildByName("tf") as TextField;
				lessonWrapper = mLessonsManager.getLessonByTitle(tf.text);
				gotoLesson(lessonWrapper, (mContext.currentLabel!="lessons"));
			}
			else if(event.target is ResourcesBtn) {
				mContext.gotoAndStop("resources");
				mContext.repositionResources();
				mContext.pause();
				mContext.setMode(Mode.MODE_VIEW_RESOURCES);
			}
			else if(event.target is QuitBtn) {
				fscommand("quit");
			}
		}
		
		/**
		 * Izvikva se, kogato cyknem s mishkata vyrhu nqkoq planeta
		 */
		public function ePlanetClick(e:PlanetMouseEvent):void {
			mContext.viewPlanet(e.planet);
		}
		
		/**
		 * Izvikva se, kogato minem s mishkata vyrhu nqkoq planeta
		 */
		public function ePlanetOver(e:PlanetMouseEvent):void {
			if (e.planet != mContext.getCurrentMouseOverPlanet())
				mContext.setCurrentMouseOverPlanet(e.planet);
		}
		
		/**
		 * Izvikva se, kogato izlezem s mishkata ot nqkoq planeta
		 */
		public function ePlanetOut(e:PlanetMouseEvent):void {
			mContext.setCurrentMouseOverPlanet(null);
		}
		
		/**
		 * Otvarq osnovnata informaciq za syotvetnata planeta.
		 */
		private function openInfo():void {
			var inf:MovieClip = mContext.getChildByName("planet_info") as MovieClip;
			var currentPlanet:CosmicBodyBase = mContext.getCurrentPlanet();
			inf.gotoAndStop(currentPlanet.getId());
			mContext.repositionPlanetInfo();
		}
		
		/**
		 * Izvikva se, kogato razglejdame planeta, urok ili pravim test i sme natisnali kopcheto "Slyncheva s-ma".
		 * Kamerata se otdalechava ot planetata i se fokusira vyrhu Slynceto, dokato ednovremenno s tova se otdalechava.
		 */
		private function returnToSystem():void {
			
			var inf:MovieClip;
			
			// ako sme natisnali kopcheto "Slyncheva s-ma" dokato razglejdame osnovna informaciq za planeta
			if(!mContext.isMode(Mode.MODE_LESSON) && !mContext.isMode(Mode.MODE_TEST)) {
				inf = mContext.getChildByName("planet_info") as MovieClip;
			}
			// ako sme natisnali kopcheto "Slyncheva s-ma" dokato chetem urok ili pravim test
			else {
				mCurrentLessonWrapper = null;
				mContext.resume();
				
				inf = mContext.getChildByName("lesson") as MovieClip;
				if(!inf)
					inf = mContext.getChildByName("test") as MovieClip;
			}
			
			initReturnTween(inf);
		}
		
		/**
		 * Pomoshtna funkciq, koqto syzdava i izpylnqva animaciqta s otdalechavaneto na planetata (napr. kogato natisnem 
		 * kopcheto "Slyncheva s-ma" razglejdaiki dadena planeta)
		 * @param inf
		 */
		private function initReturnTween(inf:MovieClip):void {
			var i:Vector3D = mCameraController.lookAtPosition.clone();
			var obj:Object = new Object();
			obj.ratio = 0;
			var t:Vector3D = new Vector3D();
			
			Tweener.addTween(inf, {alpha:0, time:Main.PLANET_INFO_SHOW_ANIM_TIME, onComplete: function() {
				Tweener.addTween(obj, {ratio: 1, time: Main.PLANET_ZOOM_ANIM_TIME, onComplete: function() {					
					mContext.setCurrentPlanet(null);
					mContext.setMode(Mode.MODE_INTRO);
					mainMenu.mouseChildren = true;
					mainMenu.mouseEnabled = true;
				}, onUpdate: function() {
					var r:Number = obj.ratio;
					mainMenu.alpha = r;
					mCameraController.lookAtPosition.setTo((t.x - i.x) * r + i.x, (t.y - i.y) * r + i.y, (t.z - i.z) * r + i.z);
				}});
				
				mContext.gotoAndStop("main");
				mContext.repositionMainMenu();
				var mainMenu:MovieClip = mContext.getChildByName("main_menu") as MovieClip;
				mainMenu.visible = true;
				mainMenu.alpha = 0;
				mainMenu.mouseChildren = false;
				mainMenu.mouseEnabled = false;
				
				var currentPlanet:CosmicBodyBase = mContext.getCurrentPlanet();
				if(currentPlanet)
					currentPlanet.selectable = true;
				mContext.setMode(Mode.MODE_PLANET_UNZOOM_ANIMATION);
				Tweener.addTween(mCameraController, {distance: Main.INITIAL_CAMERA_DIST, tiltAngle:Main.INITIAL_CAMERA_TILT_ANGLE, time: Main.PLANET_ZOOM_ANIM_TIME});
			}});
		}
		
		/**
		 * Izvikva se pri natiskane na nqkoi ot butonite "Zatvori". Razglejdame 4 sluchaq v zavisimost ot rejima na programata, v 
		 * koito sme natisnali kopcheto - rejim razglejdane na planeta, rejim chetene na urok, rejim pravene na test i rejim gledane na
		 * resursite na proekta.
		 */
		private function close():void {
			// ako razglejdame osnovnata informaciq za planetata
			if(mContext.isMode(Mode.MODE_VIEW_PLANET) || mContext.isMode(Mode.MODE_ROTATE_PLANET)) {
				var inf:MovieClip = mContext.getChildByName("planet_info") as MovieClip;
				inf.gotoAndStop("closed_mode");
				mContext.repositionPlanetInfo();
			}
			// ako natisnem kopcheto "zatvori" dokato chetem urok, zatvarqme uroka i otvarqme informaciqta za planetata
			else if(mContext.isMode(Mode.MODE_LESSON)) {						
				mCurrentLessonWrapper = null;
				
				// ako sme otvorili uroka ot kopcheto "Nauchi poveche" pri osnovnata informaciq za planetata
				var currentPlanet:CosmicBodyBase = mContext.getCurrentPlanet();
				if(currentPlanet) {
					mContext.revertMode();
					
					mContext.gotoAndStop("planet_info");
					var cont:MovieClip = mContext.getChildByName("planet_info") as MovieClip;
					cont.gotoAndStop(currentPlanet.getId());
					mContext.repositionPlanetInfo();
				}
				// ako sme otvorili uroka ot meniuto v padashtiq spisyk na nachalniq ekran
				else {
					mContext.gotoAndStop("main");
					mContext.repositionMainMenu();
					mContext.revertMode();
				}
				
				mContext.resume();
			}
			// ako natisnem kopcheto "zatvori" dokato pravim test, zatvarqme testa i otvarqme uroka
			else if(mContext.isMode(Mode.MODE_TEST)) {				
				gotoLesson(mCurrentLessonWrapper);
				mContext.setPrevMode(mTempPrevMode);
				mTempPrevMode = 0;
			}
			// ako natisnem kopcheto "zatvori" dokato razglejdame resursite na proekta
			else if(mContext.isMode(Mode.MODE_VIEW_RESOURCES)) {
				mContext.gotoAndStop("main");
				mContext.repositionMainMenu();
				mContext.revertMode();
				mContext.resume();
			}
		}
		
		/**
		 * Otiva na testa kym tekushtiq urok.
		 */
		private function gotoTest():void {
			mContext.gotoAndStop("tests");
			
			var test:MovieClip = mContext.getChildByName("test") as MovieClip;
			test.x = mContext.stage.stageWidth/2;
			test.y = mContext.stage.stageHeight/2;
			
			test.alpha = 0;
			Tweener.addTween(test, {alpha:1, time:1});
			
			mTempPrevMode = mContext.getPrevMode();
			mContext.setMode(Mode.MODE_TEST);
			mCurrentTest.init(mCurrentLessonWrapper);
		}
		
		/**
		 * Otiva na zadadeniq chrez lessonWrapper urok.
		 * @param lessonWrapper
		 * @param fadeIn Dali da se pokaje na ekrana s plavna animaciq
		 */
		private function gotoLesson(lessonWrapper:LessonWrapper, fadeIn:Boolean = false):void {
						
			mContext.gotoAndStop("lessons");
			
			var lesson:MovieClip = mContext.getChildByName("lesson") as MovieClip;			
			lesson.x = mContext.stage.stageWidth/2;
			lesson.y = mContext.stage.stageHeight/2;
			
			if(fadeIn) {
				lesson.alpha = 0;
				Tweener.addTween(lesson, {alpha:1, time:1});
			}
			
			mCurrentLessonWrapper = lessonWrapper;
			if(!mContext.isMode(Mode.MODE_TEST))
				mContext.pause();
			
			if(!mContext.isMode(Mode.MODE_LESSON))
				mContext.setMode(Mode.MODE_LESSON);
			mCurrentLesson.init(lesson, mLessons, mCurrentLessonWrapper, mCss);
		}
	}
}
