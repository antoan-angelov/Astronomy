package com.entry.astronomy {
	
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.pick.ShaderPicker;
	import away3d.debug.AwayStats;
	import away3d.entities.SegmentSet;
	import away3d.lights.PointLight;
	import away3d.primitives.LineSegment;
	
	import caurina.transitions.Tweener;
	
	import com.entry.astronomy.events.PlanetMouseEvent;
	import com.entry.astronomy.events.XmlParserEvent;
	import com.entry.astronomy.handlers.KeyboardHandler;
	import com.entry.astronomy.handlers.MouseHandler;
	import com.entry.astronomy.lessons.LessonsManager;
	import com.entry.astronomy.parser.XmlParser;
	import com.entry.astronomy.planets.CosmicBodyBase;
	import com.entry.astronomy.planets.Marker;
	import com.entry.astronomy.utils.MathUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class Main extends MovieClip {
		
		/** Kolkoto po-golqmo e chisloto, tolkova po-malka e planetata, kogato q razglejdame. */
		public static const DISTANCE_COEFF:Number = 1.8;
		/** Vremeto, za koeto animaciqta s priblijavaneto na planetata trae */
		public static const PLANET_ZOOM_ANIM_TIME:Number = 5;		
		/** Skorostta, s koqto da reagira kamerata pri dvijenie na mishkata v rejim svobodna navigaciq*/
		public static const FIRST_PERSON_ANGLE_SPEED:Number = 4;
		/** Skorostta, s koqto da reagira kamerata pri dvijenie na mishkata*/
		public static const ROTATION_ANGLE_SPEED:Number = 4;
		/** Skorostta, s koqto da se priblijava kamerata pri natiskane na strelka ili W ili S v rejim svobodna navigaciq*/
		public static const FIRST_PERSON_CAMERA_SPEED:Number = 60;
		/** Skorostta, s koqto da se priblijava kamerata pri vyrtene na kolelceto na mishkata v rejim svobodna navigaciq*/
		public static const SCROLL_CAMERA_SPEED:Number = 60;
		/** Ygylyt, koito kamerata da zaema pri razglejdane na planetata */
		public static const PLANET_ZOOM_TILT_ANGLE:Number = 15;
		/** Vremeto, za koeto animaciqta s pokazvaneto na informaciqta za planetata trae */
		public static const PLANET_INFO_SHOW_ANIM_TIME:Number = 2;
		/** Nachalna dalechina na kamerata ot Slynchevata Sistema */
		public static const INITIAL_CAMERA_DIST:Number = 22000;
		/** Nachalen vertikalen ygyl na kamerata. */
		public static const INITIAL_CAMERA_TILT_ANGLE:Number = 15;
		/** Skorostta, s koqto da se vyrti Slynchevata Sistema v nachalniq ekran */
		public static const INTRO_ROTATE_ANIM_SPEED:Number = 0.3;
		
		private var mView:View3D;
		private var light:PointLight;
		private var isMouseDown:Boolean;
		private var cosmicBodies:Array;
		private var lines:SegmentSet;
		private var mCameraController:HoverController;
		private var mUp:Boolean, mDown:Boolean;
		private var mMouseIn:Boolean;
		private var mXmlLoaded:Boolean;
		private var mLessonsManager:LessonsManager;
		private var mCss:StyleSheet;
		
		private var mMarkers:Vector.<Marker>;		
		private var mCurrentPlanet:CosmicBodyBase;
		/** tekushtiq rejim na programata **/
		private var mMode:int;
		private var currMouseOverPlanet:CosmicBodyBase;
		private var mLockRotation:Boolean;
		private var mLessons:Array;
		private var xmlParser:XmlParser;
		private var mGalleryCont:Sprite;
		private var mTestCont:Sprite;
		private var isPaused:Boolean;
		private var mPrevMode:int;
		private var mMouseHandler:MouseHandler;
		private var mKeyboardHandler:KeyboardHandler;
		private var mMarkerCont:Sprite;
		
		public function Main() {
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			
			mLockRotation = false;
			isMouseDown = false;
			mXmlLoaded = false;
			mMouseIn = false;
			mUp = mDown = false;
			mMode = Mode.MODE_LOADING;
			isPaused = false;
			mCss = new StyleSheet();

			initAway3D();
			loadCss();
			
			mGalleryCont = new Sprite();
			mTestCont = new Sprite();
			mMarkerCont = new Sprite();
			
			createContextMenu();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mEnter);
			stage.addEventListener(Event.MOUSE_LEAVE, mLeave);
			stage.addEventListener(Event.RESIZE, mResize);
		}
		
		/**
		 * Tazi funkciq syzdava kontekstovoto meniu (koeto se poqvqva s natiskane na dqsno kopche na mishkata)
		 */
		private function createContextMenu():void {
			
			var my_menu:ContextMenu = new ContextMenu();
			my_menu.hideBuiltInItems();
			
			var item1 = new ContextMenuItem("Модел на Слънчевата система");
			my_menu.customItems.push(item1);
			var item2 = new ContextMenuItem("Посети официалния сайт");
			item2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function() {
				navigateToURL(new URLRequest("http://noit2013.scienceontheweb.net/"));
			});
			my_menu.customItems.push(item2);
			var item3 = new ContextMenuItem("Създадено от Антоан Ангелов");
			my_menu.customItems.push(item3);
			
			mView.contextMenu = null;
			contextMenu = my_menu;
		}
		
		/**
		 * Inicializirame 3D sveta. Za tazi cel izpolzvame bibliotekata Away3D
		 */
		private function initAway3D():void {
			// View3D igrae rolqta na "prozorec" kym 3D sveta.
			mView = new View3D();
			mView.backgroundColor = 0x0;
			mView.width = stage.stageWidth;
			mView.height = stage.stageHeight;
			mView.mousePicker = new ShaderPicker();
			mView.camera.lens.far = Number.MAX_VALUE;
			mView.antiAlias = 4;
			addChild(mView);
			
			// inicializirame instanciq na klasa PointLight, koito ni predostavq svetlina v 3D sveta
			light = new PointLight();
			light.ambient = 0.35;
			light.castsShadows = true;
			light.diffuse = 5;
			light.specular = 1;
			
			// chrez instanciq na klasa HoverController osigurqvame mnogo po-lesno dvijenie na kamerata 
			mCameraController = new HoverController(mView.camera, null, 90, INITIAL_CAMERA_TILT_ANGLE, INITIAL_CAMERA_DIST);
			mCameraController.lookAtPosition = new Vector3D();
			mCameraController.steps = 0;
			mCameraController.autoUpdate = false;
			mCameraController.yFactor = 1;
			mCameraController.wrapPanAngle = true;
			
			// ako sme v debyg rejim, chertaem trite osi na prostranstvoto (X, Y, Z)
			if(R.DEBUG_MODE) {
				lines = new SegmentSet();
				lines.addSegment(new LineSegment(new Vector3D(), new Vector3D(0, 0, -500), 0xFF0000, 0xFF0000));
				lines.addSegment(new LineSegment(new Vector3D(), new Vector3D(0, 500, 0), 0x00FF00, 0x00FF00));
				lines.addSegment(new LineSegment(new Vector3D(), new Vector3D(500, 0, 0), 0x0000FF, 0x0000FF));
				mView.scene.addChild(lines);
				addChild(new AwayStats(mView));
			}
			
			// inicializirame xmlParser, koito otgovarq za transformaciqta na XML v 3D obekti, uroci i testove
			xmlParser = new XmlParser();
			/* zapochvame zarejdaneto na description.xml faila - v tozi fail se sydyrja informaciqta za mestopolojenieto,
			skorostite na vyrtene i dvijenie, goleminite i t.n. na planetite.*/
			xmlParser.parseDescription(this, mView, light);
			xmlParser.addEventListener(XmlParserEvent.XML_DESCRIPTION_LOADED, xmlLoaded);
		}
		
		/**
		 * Izvikva se pri orazmerqvane na prozoreca
		 */
		protected function mResize(event:Event):void {
			// Pri orazmerqvane na prozoreca orazmerqvame 3D scenata
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			mView.width = stage.stageWidth;
			mView.height = stage.stageHeight;
			mView.stage3DProxy.width = stage.stageWidth;
			mView.stage3DProxy.height = stage.stageHeight;
			
			if(currentFrameLabel == "loading") {
				repositionLoader();
			}
			// ako gledame informaciq za planeta, prenamestvame komponentite
			if(currentFrameLabel == "planet_info")
				repositionPlanetInfo();
		}
		
		/**
		 * Zarejda vynshen .CSS fail, koito shte izpolzvame pri oformlenieto na urocite
		 */
		private function loadCss():void {
			var cssLoader:URLLoader = new URLLoader();
			var cssRequest:URLRequest = new URLRequest(R.CSS_LOCATION);
			cssLoader.load(cssRequest);
			cssLoader.addEventListener(Event.COMPLETE, cssLoadComplete);
		}
		
		/**
		 * Izvikva se pri zavyrsheno zarejdane na .CSS faila.
		 */
		protected function cssLoadComplete(e:Event):void {
			mCss.parseCSS(e.target.data);
		}
		
		/**
		 * Izvikva se kogato premestim mishkata vyrhu prozoreca na programata. V DEBUG rejim programata se pauzira pri 
		 * izlizane ot ramkite na prozoreca i se puska otnovo pri vlizane na mishkata.
		 */
		protected function mEnter(event:MouseEvent):void {
			mMouseIn = true;

			if (R.DEBUG_MODE && mXmlLoaded && mMode != Mode.MODE_LESSON && mMode != Mode.MODE_TEST && isPaused)
				resume();
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mEnter);
		}
		
		/**
		 * Izvikva se, kogato mishkata izleze izvyn prozoreca na programata. V DEBUG rejim programata se pauzira pri 
		 * izlizane ot ramkite na prozoreca i se puska otnovo pri vlizane na mishkata.
		 */
		protected function mLeave(event:Event):void {
			mMouseIn = false;
			if(R.DEBUG_MODE && !isPaused)
				pause();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mEnter);
		}
		
		/**
		 * Izvikva se pri zarejdane na XML fail. Izvikva se 2 pyti - pyrviq pyt kato zaredi description.xml i
		 * vtoriq, kogato zaredi lessons.xml.
		 * @throws Error Ako lipsva zadyljitelen atribut v syotvetniq XML fail
		 * @throws Error Ako lipsva zadyljitelen tag v syotvetniq XML fail
		 */
		private function xmlLoaded(e:XmlParserEvent):void {
			// ako se e zaredil uspeshno
			if (e.status == XmlParserEvent.STATUS_OK) {
				if(R.DEBUG_MODE)
					trace("XML failyt beshe analiziran uspeshno!");
				/* ako uspeshno zaredeniqt fail e description.xml, prenasqme nujnata informaciq v syotvetnite promenlivi, 
					syzdavame nadpisite na planetite i zarejdame lessons.xml*/
				if(e.type == XmlParserEvent.XML_DESCRIPTION_LOADED) {					
					cosmicBodies = e.array;
					
					for each (var body:CosmicBodyBase in cosmicBodies) {
						var markerCont:Sprite = new Sprite();
						mMarkerCont.addChild(markerCont);
						body.setMarkerCont(markerCont);
						body.getMarker().visible = true;
					}
					
					mMarkerCont.mouseEnabled = false;
					mMarkerCont.mouseChildren = false;
					addChild(mMarkerCont);
					
					mXmlLoaded = true;										
					xmlParser.parseLessons(this);
					xmlParser.addEventListener(XmlParserEvent.XML_LESSONS_LOADED, xmlLoaded);
				}
				// ako uspeshno zaredeniqt fail e description.xml, prenasqme nujnata informaciq v syotvetnite promenlivi
				else if(e.type == XmlParserEvent.XML_LESSONS_LOADED) {
					mLessons = e.array;
					mLessonsManager = new LessonsManager(mLessons);					
					gotoAndStop("main");
					repositionMainMenu();
					mMode = Mode.MODE_INTRO;
					// syzdavame instancii na MouseHandler i KeyboardHandler - te otgovarqt za obrabotkata na sybitiqta syotvetno s mishka i klaviatura
					mMouseHandler = new MouseHandler(this, mView, mGalleryCont, mTestCont, mLessonsManager, mCameraController, mCss);
					mKeyboardHandler = new KeyboardHandler(this);
					resume();
				}
			}
			// ako lipsva zadyljitelen atribut, hvyrlqme greshka
			else if (e.status == XmlParserEvent.STATUS_MISSING_ATTRIBUTE) {
				throw new Error("Lipsvasht ili zanulen atribut v opisatelniq XML fail! Molq poglednete shablona na syotvetniq XML fail! " + (e.info !=
					null ? e.info : ""));
			}
			// ako lipsva zadyljitelen tag, hvyrlqme greshka
			else if (e.status == XmlParserEvent.STATUS_MISSING_TAG) {
				throw new Error("Lipsvasht tag v opisatelniq XML fail! Molq poglednete shablona na syotvetniq XML fail! " + (e.info != null ? e.info :
					""));
			}
		}
		
		/**
		 * Pauzira programata i dobavq cheren fon sys 70% vidimost.
		 */
		public function pause():void {
			
			isPaused = true;
			
			this.graphics.beginFill(0x000000, 0.7);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
			mMarkerCont.alpha = 0.3;
			
			// za da pauzirame programata, deregistrirame slushatelite
			removeEventListener(Event.ENTER_FRAME, update);
			if(mMouseHandler) {
				stage.removeEventListener(MouseEvent.MOUSE_OVER, mMouseHandler.mOver);
				stage.removeEventListener(MouseEvent.MOUSE_OUT, mMouseHandler.mOut);
				removeEventListener(MouseEvent.MOUSE_DOWN, mMouseHandler.mDown);
				removeEventListener(MouseEvent.MOUSE_UP, mMouseHandler.mUp);
				removeEventListener(MouseEvent.MOUSE_WHEEL, mMouseHandler.mWheel);
				mView.scene.removeEventListener(PlanetMouseEvent.OVER, mMouseHandler.ePlanetOver);
				mView.scene.removeEventListener(PlanetMouseEvent.OUT, mMouseHandler.ePlanetOut);
				mView.scene.removeEventListener(PlanetMouseEvent.CLICK, mMouseHandler.ePlanetClick);
			}
			
			if(mKeyboardHandler) {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, mKeyboardHandler.kDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, mKeyboardHandler.kUp);
			}
		}
		
		/**
		 * Resume-va programata.
		 */
		public function resume():void {
			
			isPaused = false;
			
			this.graphics.clear();
			mMarkerCont.alpha = 1;
			
			// registrirame nujnite slushateli
			addEventListener(Event.ENTER_FRAME, update);
			
			if(mMouseHandler) {
				addEventListener(MouseEvent.CLICK, mMouseHandler.mClick);
				stage.addEventListener(MouseEvent.MOUSE_OVER, mMouseHandler.mOver);
				stage.addEventListener(MouseEvent.MOUSE_OUT, mMouseHandler.mOut);
				addEventListener(MouseEvent.MOUSE_DOWN, mMouseHandler.mDown);
				addEventListener(MouseEvent.MOUSE_UP, mMouseHandler.mUp);
				addEventListener(MouseEvent.MOUSE_WHEEL, mMouseHandler.mWheel);
				mView.scene.addEventListener(PlanetMouseEvent.OVER, mMouseHandler.ePlanetOver);
				mView.scene.addEventListener(PlanetMouseEvent.OUT, mMouseHandler.ePlanetOut);
				mView.scene.addEventListener(PlanetMouseEvent.CLICK, mMouseHandler.ePlanetClick);
			}
			
			if(mKeyboardHandler) {
				stage.addEventListener(KeyboardEvent.KEY_DOWN, mKeyboardHandler.kDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, mKeyboardHandler.kUp);
			}
		}		
		
		/**
		 * Fokusira konkretna planeta. Vkliuchva i cqlata animaciq za priblijavaneto i.
		 * @param planet Planetata, koqto da doblijim
		 */
		public function viewPlanet(planet:CosmicBodyBase):void {
			
			// ako planet e null ili v momenta sme v rejim animaciq, se mahame ot funkciqta
			if (planet == mCurrentPlanet || mMode == Mode.MODE_PLANET_ZOOM_ANIMATION || mMode == Mode.MODE_PLANET_UNZOOM_ANIMATION)
				return;
			
			/* ako sme izbrali planetata, koqto iskame da vidim, dokato sme razglejdali druga planeta, 
			vryshtame nastroikite na drugata planeta */
			if (mCurrentPlanet) {
				mCurrentPlanet.selectable = true;
				var infoObj:DisplayObject = getChildByName("planet_info");
				Tweener.addTween(infoObj, {alpha:0, time:PLANET_INFO_SHOW_ANIM_TIME});
			}
			
			mMode = Mode.MODE_PLANET_ZOOM_ANIMATION;
			
			mCurrentPlanet = planet;
			planet.selectable = false;
			
			var i:Vector3D = mCameraController.lookAtPosition.clone();
			var initialPanAngle:Number = mCameraController.panAngle;
			var pos:Vector3D = planet.scenePosition;
			var obj:Object = new Object();
			obj.ratio = 0;
			var mainMenuTest:DisplayObject = getChildByName("main_menu");
			if(mainMenuTest) {
				var mainMenu:MovieClip = mainMenuTest as MovieClip;
				mainMenu.mouseChildren = false;
				mainMenu.mouseEnabled = false;
			}
			
			// Tuk syzdavame animaciqta, koqto nasochva kamerata pod podhodqsht ygyl sprqmo planetata
			Tweener.addTween(obj, {ratio: 1, time: PLANET_ZOOM_ANIM_TIME, onComplete: function() {
				mMode = Mode.MODE_VIEW_PLANET;
				gotoAndStop("planet_info");
				var infoObj:MovieClip = getChildByName("planet_info") as MovieClip;
				infoObj.gotoAndStop(planet.getId());
				infoObj.alpha = 0;
				Tweener.addTween(infoObj, {alpha:1, time:PLANET_INFO_SHOW_ANIM_TIME});
				repositionPlanetInfo();
				if(mainMenu)
					mainMenu.visible = false;
				
			}, onUpdate: function() {
				var t:Vector3D = planet.scenePosition;
				var r:Number = obj.ratio;
				var ang:Number = MathUtils.getAngle(t.x, t.z) * 180 / Math.PI + 90;			
				
				if(mainMenu)
					mainMenu.alpha = 1-r;
				mCameraController.lookAtPosition.setTo((t.x - i.x) * r + i.x, (t.y - i.y) * r + i.y, (t.z - i.z) * r + i.z);
				mCameraController.panAngle = (ang - initialPanAngle) * r + initialPanAngle;
			}});
			
			// Tuk syzdavame animaciqta, koqto priblijava kamerata kym planetata
			Tweener.addTween(mCameraController, {distance: 2 * planet.getRadius() * DISTANCE_COEFF, tiltAngle: PLANET_ZOOM_TILT_ANGLE, 
				time: PLANET_ZOOM_ANIM_TIME});
		}
		
		/**
		 * Tazi funkciq izchislqva poziciite na komponentite pri ekrana s resursite, za da izglejda dobre na vsqkakvi ekrani.
		 */
		public function repositionResources():void {
			var cont:MovieClip = getChildByName("resources") as MovieClip;
			cont.x = stage.stageWidth*0.5;
			cont.y = stage.stageHeight*0.5;
		}
		
		/**
		 * Tazi funkciq izchislqva poziciite na komponentite pri glavniq ekran (s vsichki planeti), za da izglejda dobre na vsqkakvi ekrani.
		 */
		public function repositionMainMenu():void {
			var cont:MovieClip = getChildByName("main_menu") as MovieClip;
			var comp:MovieClip = cont.getChildByName("top_right") as MovieClip;
			comp.x = stage.stageWidth;
			comp.y = 0;
		}
		
		/**
		 * Tazi funkciq izchislqva poziciite na komponentite pri nachalnoto zarejdane, za da izglejda dobre na vsqkakvi ekrani.
		 */
		private function repositionLoader():void {
			if(currentLabel != "loading")
				return;
			
			var loader:MovieClip = getChildByName("loading") as MovieClip;
			loader.x = (stage.stageWidth-loader.width)*0.5;
			loader.y = (stage.stageHeight-loader.height)*0.5;
		}
		
		/**
		 * Tazi funkciq izchislqva poziciite na komponentite pri osnovnata informaciq za planetata, za da izglejda dobre na vsqkakvi ekrani.
		 */
		public function repositionPlanetInfo():void {
			
			if(currentLabel != "planet_info")
				return;
			
			var inf:DisplayObjectContainer = getChildByName("planet_info") as DisplayObjectContainer;
			var infoCont:MovieClip = inf.getChildByName("cont") as MovieClip;			
			var w:Number, h:Number;
			var stageW:Number = stage.stageWidth, stageH:Number = stage.stageHeight;
			
			/* obhojdame vseki element i gledame imeto mu - ako e primerno "center_left", znachi trqbva da go centrirame vertikalno 
			i da go podravnim v lqvo*/
			for (var i:int = 0; i < infoCont.numChildren; i++) {
				var displayObj:DisplayObject = infoCont.getChildAt(i);
			
				if (displayObj is MovieClip) {
					var mc:MovieClip = displayObj as MovieClip;
					w = mc.width;
					h = mc.height;
				}
				else if (displayObj is TextField) {
					var tf:TextField = displayObj as TextField;
					w = tf.width;
					h = tf.height;
				}
				else
					continue;

				var name:String = displayObj.name;
				var ind:int = name.indexOf("_"), ver:String = name.substr(0, ind), hor:String = name.substr(ind + 1);

				if (ver == "top")
					displayObj.y = 0;
				else if (ver == "bottom")
					displayObj.y = stageH;
				else if (ver == "center") {
					displayObj.y = 0.5 * stageH;
				}
				
				if (hor == "left")
					displayObj.x = 0;
				else if (hor == "right")
					displayObj.x = stageW;
				else if (hor == "center")
					displayObj.x = 0.5 * stageW;
			}
		}
		
		/**
		 * Izvikva se na vseki kadyr. Tuk se osyshtestvqva dvijenieto na planetite i kamerata.
		 */
		protected function update(event:Event):void {

			if (mCurrentPlanet && (mMode == Mode.MODE_VIEW_PLANET || mMode == Mode.MODE_ROTATE_PLANET)) {
				
				var pos:Vector3D = mCurrentPlanet.scenePosition;
				mCameraController.lookAtPosition.setTo(pos.x, pos.y, pos.z);
				
				if (mMode == Mode.MODE_VIEW_PLANET) {
					var ang:Number = MathUtils.getAngle(pos.x, pos.z) * 180 / Math.PI + 90;
					mCameraController.panAngle = ang;					
					mCameraController.distance = 2 * mCurrentPlanet.getRadius() * DISTANCE_COEFF;
				}
			}
			
			// Dvijim kamerata
			handleCameraMovement();
			
			if (mMode != Mode.MODE_FIRST_PERSON)
				mCameraController.update();
			
			// Dvijim planetite
			for each (var body:CosmicBodyBase in cosmicBodies) {
				if (body.isMovable())
					body.moveAlongOrbit();
				body.update();
			}
			
			// render-vame 3D sveta
			mView.render();
			
			// ako mishkata e izvyn ekrana v DEBUG rejim, pauzirame programata
			if (R.DEBUG_MODE && !mMouseIn)
				pause();
			
			// dobavqme i nadpisite na planetite, ako ne sa dobaveni
			if (!mMarkers) {
				mMarkers = new Vector.<Marker>();
				for each (body in cosmicBodies) {
					body.getMarker().visible = true;
					mMarkers.push(body.getMarker());
				}
			}
		}
		
		/**
		 * Tazi funkciq se griji za dvijenieto na kamerata.
		 */
		private function handleCameraMovement():void {
			
			// pri natisnata strelka ili W ili D kopche, dvijim kamerata napred ili nazad
			if (mUp) {				
				mView.camera.moveForward(FIRST_PERSON_CAMERA_SPEED);
				mCameraController.distance -= FIRST_PERSON_CAMERA_SPEED;
			}
			else if (mDown) {				
				mView.camera.moveBackward(FIRST_PERSON_CAMERA_SPEED);
				mCameraController.distance += FIRST_PERSON_CAMERA_SPEED;
			}
			
			// ako zadyrjim dqsnoto kopche na mishkata i q myrdame, se myrda i kamerata v syotvetnata posoka
			if (isMouseDown && !mLockRotation && mMode != Mode.MODE_PLANET_ZOOM_ANIMATION && mMode != Mode.MODE_VIEW_PLANET && mMode != Mode.MODE_PRESS_PLANET) {
				
				var k1:Number = ((mouseX - stage.stageWidth * 0.5) / (stage.stageWidth * 0.5));
				var k2:Number = ((mouseY - stage.stageHeight * 0.5) / (stage.stageHeight * 0.5));
				
				if (mMode == Mode.MODE_ROTATE_SOLAR_SYSTEM || mMode == Mode.MODE_ROTATE_PLANET) {
					mCameraController.panAngle += ROTATION_ANGLE_SPEED * k1;
					mCameraController.tiltAngle += ROTATION_ANGLE_SPEED * k2;
				}
				else {
					
					mView.camera.rotationX = MathUtils.normalize(mView.camera.rotationX, FIRST_PERSON_ANGLE_SPEED * k2);
					mView.camera.rotationY = MathUtils.normalize(mView.camera.rotationY, FIRST_PERSON_ANGLE_SPEED * k1);
					
					if (mView.camera.rotationX < -90)
						mView.camera.rotationX = -90;
					else if (mView.camera.rotationX > 90)
						mView.camera.rotationX = 90;
				}
			}
			
			// nachalnata animaciq na vyrtene na Slynchevata Sistema
			if (mMode == Mode.MODE_INTRO || mMode == Mode.MODE_PLANET_UNZOOM_ANIMATION) {
				mCameraController.panAngle += INTRO_ROTATE_ANIM_SPEED;
			}
		}
		
		/* GETTERS & SETTERS */
		
		public function setMode(mode:int):void {
			mPrevMode = mMode;
			mMode = mode;
		}
		
		public function isMode(mode:int):Boolean {
			return mMode == mode;
		}
		
		public function getCurrentPlanet():CosmicBodyBase {
			return mCurrentPlanet;
		}
		
		public function setCurrentPlanet(planet:CosmicBodyBase):void {
			mCurrentPlanet = planet;
		}
		
		public function getCurrentMouseOverPlanet():CosmicBodyBase {
			return currMouseOverPlanet;
		}
		
		public function setCurrentMouseOverPlanet(planet:CosmicBodyBase):void {
			currMouseOverPlanet = planet;
		}
		
		public function canSelect():Boolean {
			return false;
		}
		
		public function revertMode():void {
			mMode = mPrevMode;
			mPrevMode = 0;
		}
		
		public function getMode():int {
			return mMode;
		}
		
		public function getPrevMode():int {
			return mPrevMode;
		}
		
		public function setLockRotation(lock:Boolean):void {
			mLockRotation = lock;
		}
		
		public function setIsMouseDown(b:Boolean):void {
			isMouseDown = b;
		}
		
		public function setUp(up:Boolean):void {
			mUp = up;
		}
		
		public function setDown(down:Boolean):void {
			mDown = down;
		}
		
		public function setPrevMode(prevMode:int):void {
			mPrevMode = prevMode;
		}
		
		public function toggleFullscreen():void {
			if(stage.displayState != StageDisplayState.FULL_SCREEN)
				stage.displayState = StageDisplayState.FULL_SCREEN;
			else
				stage.displayState = StageDisplayState.NORMAL;
		}
	}
}
