package com.entry.astronomy.parser {
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.base.SubGeometry;
	import away3d.core.math.Plane3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.SpecularShadingModel;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.tools.helpers.MeshHelper;
	
	import com.entry.astronomy.wrappers.AnswerWrapper;
	import com.entry.astronomy.wrappers.ImageWrapper;
	import com.entry.astronomy.wrappers.LessonWrapper;
	import com.entry.astronomy.wrappers.QuestionWrapper;
	import com.entry.astronomy.wrappers.TestWrapper;
	import com.entry.astronomy.events.XmlParserEvent;
	import com.entry.astronomy.planets.CosmicBody2D;
	import com.entry.astronomy.planets.CosmicBody3D;
	import com.entry.astronomy.planets.CosmicBodyBase;
	import com.entry.astronomy.planets.Orbit;
	import com.entry.astronomy.planets.Ring;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.entry.astronomy.wrappers.LoaderInfoWrapper;
	import com.entry.astronomy.Main;
	import com.entry.astronomy.R;
	
	/**
	 * Zarejda i prenasq informaciqta ot XML fail vyv vizualen vid. Syzdava 3D obektite, urocite i testovete kym tqh.
	 * @author Antoan Angelov
	 */
	public class XmlParser extends EventDispatcher {
		
		public static const TAG_SOLAR_SYSTEM:String = "SolarSystem";
		public static const TAG_SUN:String = "Sun";
		public static const TAG_PLANET:String = "Planet";
		public static const TAG_MOON:String = "Moon";
		public static const TAG_ORBIT:String = "Orbit";
		public static const TAG_RING:String = "Ring";
		public static const TAG_LESSONS:String = "Lessons";
		public static const TAG_LESSON:String = "Lesson";
		public static const TAG_HTML_TEXT:String = "HtmlText";
		public static const TAG_IMG:String = "img";
		public static const TAG_IMAGES:String = "Images";
		public static const TAG_TEST:String = "Test";
		public static const TAG_QUESTION:String = "Question";
		public static const TAG_ANSWER:String = "Answer";
		
		public static const ATTRIBUTE_NAME:String = "name";
		public static const ATTRIBUTE_ID:String = "id";
		public static const ATTRIBUTE_TITLE:String = "title";
		public static const ATTRIBUTE_CONTENT:String = "content";
		public static const ATTRIBUTE_MAP:String = "map";
		public static const ATTRIBUTE_NORMAL_MAP:String = "normalMap";
		public static const ATTRIBUTE_RADIUS:String = "radius";
		public static const ATTRIBUTE_SIDE:String = "side";
		public static const ATTRIBUTE_ROTATION_SPEED:String = "rotationSpeed";
		public static const ATTRIBUTE_SEGMENTS_W:String = "segmentsW";
		public static const ATTRIBUTE_SEGMENTS_H:String = "segmentsH";
		public static const ATTRIBUTE_RIGHT_ASCENSION:String = "rightAscension";
		public static const ATTRIBUTE_DECLINATION:String = "declination";
		public static const ATTRIBUTE_NUM_MESHES:String = "numMeshes";
		public static const ATTRIBUTE_THICKNESS:String = "thickness";
		public static const ATTRIBUTE_TRUE_ANOMALY:String = "trueAnomaly";
		public static const ATTRIBUTE_INCLINATION:String = "inclination";
		public static const ATTRIBUTE_ARGUMENT_OF_PERIAPSIS:String = "argumentOfPeriapsis";
		public static const ATTRIBUTE_LONGITUDE_OF_ASCENDING_NODE:String = "longitudeOfAscendingNode";
		public static const ATTRIBUTE_SEMI_MINOR_AXIS:String = "semiMinorAxis";
		public static const ATTRIBUTE_SEMI_MAJOR_AXIS:String = "semiMajorAxis";
		public static const ATTRIBUTE_SPEED_COEFF:String = "speedCoeff";
		public static const ATTRIBUTE_COLOR:String = "color";
		public static const ATTRIBUTE_SRC:String = "src";
		public static const ATTRIBUTE_DESCR:String = "descr";
		public static const ATTRIBUTE_VALUE:String = "value";
		public static const ATTRIBUTE_CORRECT:String = "correct";
		
		private static const FLAG_SUN:int = 1;
		private static const FLAG_SOLAR_SYSTEM:int = 2;
		
		private var mContext:Main;
		private var mWorld:View3D;
		private var mScene:Scene3D;
		private var mLoaderInfoQueue:Vector.<LoaderInfoWrapper>;
		private var mArray:Array;
		private var mLoader:Loader;
		private var mLight:PointLight;
		private var mStatus:int;
		private var mInfo:String;
		private var mLoaderInfo:LoaderInfoWrapper;
		private var mEventType:String;
		
		private var mLightPicker:StaticLightPicker;		
		
		public function XmlParser(target:IEventDispatcher = null) {
			super(target);
		}
		
		/**
		 * Zarejda description.xml
		 * @param context
		 * @param world
		 * @param light
		 */
		public function parseDescription(context:Main, world:View3D, light:PointLight):void {
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, descriptionXmlLoaded);
			xmlLoader.load(new URLRequest(R.DESCRIPTOR_LOCATION));
			
			this.mContext = context;
			this.mWorld = world;
			this.mScene = world.scene;
			this.mLight = light;
			
			mEventType = XmlParserEvent.XML_DESCRIPTION_LOADED;
		}
		
		/**
		 * Zarejda lessons.xml
		 * @param context
		 */
		public function parseLessons(context:Main):void {
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, lessonsXmlLoaded);
			xmlLoader.load(new URLRequest(R.LESSONS_LOCATION));
			
			this.mContext = context;
			
			mEventType = XmlParserEvent.XML_LESSONS_LOADED;
		}
		
		/**
		 * Pri zareden description.xml, zapochvame samoto parsvane
		 * @param e
		 */
		private function descriptionXmlLoaded(e:Event):void {
			
			var xml:XMLList = new XMLList(e.target.data);
			mStatus = parseDescriptionXML(xml);
			
			if (mStatus != XmlParserEvent.STATUS_OK)
				dispatchEvent(new XmlParserEvent(mEventType, mStatus, null, mInfo));
		}
		
		/**
		 * Pri zareden lessons.xml, zapochvame samoto parsvane
		 * @param e
		 */
		protected function lessonsXmlLoaded(e:Event):void {
			var xml:XMLList = new XMLList(e.target.data);
			mStatus = parseLessonsXML(xml);
			
			if (mStatus != XmlParserEvent.STATUS_OK)
				dispatchEvent(new XmlParserEvent(mEventType, mStatus, null, mInfo));
			else
				dispatchEvent(new XmlParserEvent(mEventType, mStatus, mArray));
		}
		
		/**
		 * Syshtinskoto parsvane na lessons.xml. Syzdavat se instancii na nujnite klasove i se syhranqvat pod formata na masiv.
		 * @param xml
		 * @return 
		 */
		private function parseLessonsXML(xml:XMLList):int {
			
			mArray = [];

			if(xml.name() == TAG_LESSONS) {
				
				var lessonsList:XMLList = xml[TAG_LESSON] as XMLList;
				
				// pyrvo obhojdame vsichki tagove <Lesson>
				for each (var lessonXml:XML in lessonsList) {
					var htmlText:String = lessonXml[TAG_HTML_TEXT][0].toString();
					htmlText = htmlText.replace(/(\t|\n|\r)/gi, "");
					var images:Vector.<ImageWrapper> = new Vector.<ImageWrapper>();
					
					// ako ima kartinki, obhojdame i tqh
					if(lessonXml.hasOwnProperty(TAG_IMAGES)) {						
						for each (var imgXml:XML in lessonXml[TAG_IMAGES][TAG_IMG]) {
							var image:ImageWrapper = new ImageWrapper(imgXml["@"+ATTRIBUTE_SRC], imgXml["@"+ATTRIBUTE_DESCR]);
							images.push(image);
						}
					}
					else {
						mInfo = "[ lipsva tag Images ]";
						return XmlParserEvent.STATUS_MISSING_TAG;
					}
					
					var questions:Vector.<QuestionWrapper> = new Vector.<QuestionWrapper>();
					
					// nakraq obhojdame i testa, ako ima takyv
					if(lessonXml.hasOwnProperty(TAG_TEST)) {						
						for each (var questionXml:XML in lessonXml[TAG_TEST][TAG_QUESTION]) {
							
							var answers:Vector.<AnswerWrapper> = new Vector.<AnswerWrapper>();
							
							for each(var answerXml:XML in questionXml[TAG_ANSWER]) {
								var correct:Boolean = (answerXml.hasOwnProperty("@"+ATTRIBUTE_CORRECT) ? answerXml["@"+ATTRIBUTE_CORRECT]==true : false);
								var answer:AnswerWrapper = new AnswerWrapper(answerXml["@"+ATTRIBUTE_VALUE], correct);
								answers.push(answer);
							}
							
							var question:QuestionWrapper = new QuestionWrapper(questionXml["@"+ATTRIBUTE_VALUE], answers);
							questions.push(question);
						}
					}
					else {
						mInfo = "[ lipsva tag Test ]";
						return XmlParserEvent.STATUS_MISSING_TAG;
					}
					
					var testWrapper:TestWrapper = new TestWrapper(questions);
					
					// syhranqvame cqlata informaciq v instanciq na LessonWrapper
					var lesson:LessonWrapper = new LessonWrapper(lessonXml["@"+ATTRIBUTE_ID], lessonXml["@"+ATTRIBUTE_TITLE], 
						htmlText, images, testWrapper);
					// dobavqme tazi instanciq kym masiv
					mArray.push(lesson);
				}
			}
			else {
				mInfo = "[ lipsva tag Lessons ]";
				return XmlParserEvent.STATUS_MISSING_TAG;
			}
			
			return XmlParserEvent.STATUS_OK;
		}
		
		/**
		 * Syshtinskoto parsvane na description.xml. Tuk se syzdavat vsichki 3D obekti.
		 * @param xml
		 * @return 
		 */
		private function parseDescriptionXML(xml:XMLList):int {
			
			mLoaderInfoQueue = new Vector.<LoaderInfoWrapper>();
			mArray = [];
			var loaderInfo:LoaderInfoWrapper;
			
			mLightPicker = new StaticLightPicker([mLight]);
			
			xml.ignoreWhitespace = true;
			
			// Pyrvo gledame za nalichieto na tag <SolarSystem>
			if (xml.name() == TAG_SOLAR_SYSTEM) {
				
				if(!xml.hasOwnProperty("@"+ATTRIBUTE_RADIUS) || !xml.hasOwnProperty("@"+ATTRIBUTE_SEGMENTS_W) 
					|| !xml.hasOwnProperty("@"+ATTRIBUTE_SEGMENTS_H)) {
					
					mInfo = "[ lipsva atribut "+ATTRIBUTE_RADIUS+", "+ATTRIBUTE_SEGMENTS_W+" ili "+ATTRIBUTE_SEGMENTS_H+" v taga "+TAG_SOLAR_SYSTEM+" ]";
					return XmlParserEvent.STATUS_MISSING_ATTRIBUTE;
				}
				
				// Inicializirame golqma sfera, s parametrite, zadadeni v XML taga i zarejdame teksturata i
				var sphereGeo:SphereGeometry = new SphereGeometry(xml.@[ATTRIBUTE_RADIUS], xml.@[ATTRIBUTE_SEGMENTS_W], xml.@[ATTRIBUTE_SEGMENTS_H]);
				var background:Mesh = new Mesh(sphereGeo);
				MeshHelper.invertFaces(background);
				
				loaderInfo = new LoaderInfoWrapper();
				loaderInfo.mesh = background;
				loaderInfo.map = xml.@[ATTRIBUTE_MAP];
				loaderInfo.flags |= FLAG_SOLAR_SYSTEM;
				mLoaderInfoQueue.push(loaderInfo);
				
				background.name = "background";
				mScene.addChild(background);
			}
			else {
				mInfo = "[ lipsva tag SolarSystem ]";
				return XmlParserEvent.STATUS_MISSING_TAG;
			}
			
			// Gledame za nalichieto na taga <Sun>
			if (xml.hasOwnProperty(TAG_SUN)) {
				
				var sunXml:XML = (xml[TAG_SUN] as XMLList)[0];	
				if(!sunXml.hasOwnProperty("@"+ATTRIBUTE_NAME) || !sunXml.hasOwnProperty("@"+ATTRIBUTE_ID) || 
					!sunXml.hasOwnProperty("@"+ATTRIBUTE_SIDE) || !sunXml.hasOwnProperty("@"+ATTRIBUTE_MAP)) {
					
					mInfo = "[ lipsva atribut "+ATTRIBUTE_NAME+", "+ATTRIBUTE_ID+", "+ATTRIBUTE_SIDE+" ili "+ATTRIBUTE_MAP+" v taga "
						+TAG_SUN+" ]";
					return XmlParserEvent.STATUS_MISSING_ATTRIBUTE;
				}				
				
				var name:String = sunXml.@[ATTRIBUTE_NAME];
				var id:String = sunXml.@[ATTRIBUTE_ID];
				var side:Number = sunXml.@[ATTRIBUTE_SIDE];
				var planeGeo:PlaneGeometry = new PlaneGeometry(side, side);
				var plane:Mesh = new Mesh(planeGeo);
				
				// Zarejdame teksturata na Slynceto
				loaderInfo = new LoaderInfoWrapper();
				loaderInfo.mesh = plane;
				loaderInfo.map = sunXml.@[ATTRIBUTE_MAP];
				loaderInfo.flags |= FLAG_SUN;
				mLoaderInfoQueue.push(loaderInfo);
				
				plane.name = "sun";
				
				// Syzdavame i ploska povyrhnost, koqto vinagi shte gleda kym kamerata - tova shte predstavlqva Slynceto
				var sun:CosmicBody2D = new CosmicBody2D(mContext, mWorld, name, id, side*0.5, CosmicBodyBase.TYPE_SUN);
				sun.addPlane(plane);
				mArray.push(sun);
				mScene.addChild(sun);				
			}
			else {
				mInfo = "[ lipsva tag Sun ]";
				return XmlParserEvent.STATUS_MISSING_TAG;
			}
			
			// Obhojdame i vsichki tagove <Planet>
			for each (var planetXml:XML in xml[TAG_SUN][TAG_PLANET]) {
				
				// Za vseki tag <Planet> syzdavame syotvetna instanciq na klasa CosmicBody3D
				var planet:CosmicBody3D = buildCosmicBody(planetXml, CosmicBodyBase.TYPE_PLANET, sun);
				if (!planet)
					return mStatus;
				
				planet.name = "cosmicBody";
				mScene.addChild(planet);
				
				// Obhojdame i vsichki luni na vsqka planeta
				for each (var moonXml:XML in planetXml[TAG_MOON]) {
					
					// Za vseki tag <Moon> syzdavame syotvetna instanciq na klasa CosmicBody3D
					var moon:CosmicBody3D = buildCosmicBody(moonXml, CosmicBodyBase.TYPE_MOON, planet);
					if (!moon)
						return mStatus;
					
					planet.addMoon(moon);
				}
			}
			
			mLoader = new Loader();
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			loadNext();
			
			return XmlParserEvent.STATUS_OK;
		}
		
		/**
		 * Syzdava instanciq na CosmicBody3D, vzimaiki v predvid parametrite ot syotvetniq XML tag.
		 * @param xml
		 * @param type
		 * @param centerBody
		 * @param flags
		 * @return 
		 */
		private function buildCosmicBody(xml:XML, type:int, centerBody:ObjectContainer3D = null, flags:int = 0):CosmicBody3D {
			
			// vzimame informaciq za vsichki atributi ot syotvetniq tag
			var tag:String = xml.localName();
			var map:String = xml.@[ATTRIBUTE_MAP];
			var normalMap:String = xml.@[ATTRIBUTE_NORMAL_MAP];
			var name:String = xml.@[ATTRIBUTE_NAME];
			var id:String = xml.@[ATTRIBUTE_ID];
			var radius:Number = xml.@[ATTRIBUTE_RADIUS];
			var segW:int = xml.@[ATTRIBUTE_SEGMENTS_W];
			var segH:int = xml.@[ATTRIBUTE_SEGMENTS_H];
			var rotSpeed:Number = xml.@[ATTRIBUTE_ROTATION_SPEED];
			var rightAsc:Number = xml.@[ATTRIBUTE_RIGHT_ASCENSION];
			var decl:Number = xml.@[ATTRIBUTE_DECLINATION];
			
			var cosmicBody:CosmicBody3D = new CosmicBody3D(mContext, mWorld, type, tag, name, id, map, normalMap, radius, segW, segH, 
				rotSpeed, rightAsc, decl);
			
			if (!name || !id || !map || !radius || !segW || !segH) {
				setError(XmlParserEvent.STATUS_MISSING_ATTRIBUTE, cosmicBody.toString());
				return null;
			}
			
			cosmicBody.init();
			
			// dobavqme i vizualna interpretaciq na orbitata na planetata, ako sme posochili takava v XML faila
			if (xml.hasOwnProperty(TAG_ORBIT) && centerBody) {
				
				var orbitXml:XMLList = xml[TAG_ORBIT];
				
				var color:uint = orbitXml.@[ATTRIBUTE_COLOR];
				var speedCoeff:Number = orbitXml.@[ATTRIBUTE_SPEED_COEFF];
				var trueAn:Number = orbitXml.@[ATTRIBUTE_TRUE_ANOMALY];
				var incl:Number = orbitXml.@[ATTRIBUTE_INCLINATION];
				var aop:Number = orbitXml.@[ATTRIBUTE_ARGUMENT_OF_PERIAPSIS];
				var lan:Number = orbitXml.@[ATTRIBUTE_LONGITUDE_OF_ASCENDING_NODE];
				var min:Number = orbitXml.@[ATTRIBUTE_SEMI_MINOR_AXIS];
				var max:Number = orbitXml.@[ATTRIBUTE_SEMI_MAJOR_AXIS];				
				
				if(!orbitXml.hasOwnProperty("@" + ATTRIBUTE_COLOR)) {
					color = 0x292929;
				}

				var orbit:Orbit = new Orbit(cosmicBody, centerBody, color, speedCoeff, trueAn, incl, aop, lan, min, max);
				
				if (!min || !max || !speedCoeff
					|| !orbitXml.hasOwnProperty("@" + ATTRIBUTE_INCLINATION)
					|| !orbitXml.hasOwnProperty("@" + ATTRIBUTE_ARGUMENT_OF_PERIAPSIS)
					|| !orbitXml.hasOwnProperty("@" + ATTRIBUTE_LONGITUDE_OF_ASCENDING_NODE)) {
					
					setError(XmlParserEvent.STATUS_MISSING_ATTRIBUTE, orbit.toString());
					return null;
				}				
				
				orbit.init();
			}
			else if (centerBody) {
				setError(XmlParserEvent.STATUS_MISSING_TAG, "[ lipsva tag Orbit ]");
				return null;
			}
			
			// syzdavame obekt ot klasa LoaderInfoWrapper, koito syhranqva informaciq za teksturite, koito da zaredi
			var loaderInfo:LoaderInfoWrapper = new LoaderInfoWrapper();
			loaderInfo.cosmicBody = cosmicBody;
			loaderInfo.mesh = cosmicBody.getPlanet();
			loaderInfo.map = map;
			loaderInfo.flags |= flags;
			
			if (xml.hasOwnProperty("@" + ATTRIBUTE_NORMAL_MAP)) {
				loaderInfo.normalMap = normalMap;
			}
			
			// ako planetata ima prysten, dobavqme i nego
			if (xml.hasOwnProperty(TAG_RING)) {
				var ringXml:XMLList = xml[TAG_RING];
				var ringRadius:Number = ringXml.@[ATTRIBUTE_RADIUS];
				var ringNumMeshes:int = ringXml.@[ATTRIBUTE_NUM_MESHES];
				var ringThickness:Number = ringXml.@[ATTRIBUTE_THICKNESS];
				
				var ring:Ring = new Ring(cosmicBody, radius, ringNumMeshes, ringThickness);
				
				if (!ringXml.hasOwnProperty("@" + ATTRIBUTE_RADIUS)
					|| !ringXml.hasOwnProperty("@" + ATTRIBUTE_NUM_MESHES)
					|| !ringXml.hasOwnProperty("@" + ATTRIBUTE_THICKNESS)) {
					
					setError(XmlParserEvent.STATUS_MISSING_ATTRIBUTE, ring.toString());
					return null;
				}
				
				ring.init();
				
				var ringMap:String = ringXml.@[ATTRIBUTE_MAP];
				loaderInfo.ringMap = ringMap;
			}
			
			mArray.push(cosmicBody);
			// dobavqme LoaderInfoWrapper instanciqta kym opashka, koqto se polzva za zarejdane na kartinkite edna po edna
			mLoaderInfoQueue.push(loaderInfo);
			
			return cosmicBody;
		}
		
		private function setError(status:int, info:String = null):void {
			mStatus = status;
			mInfo = info;
		}
		
		/**
		 * Izvikva se pri zaredena kartinka. Dobavq kartinkata kato tekstura, ili relefna karta kym syotvetniq 3D obekt.
		 */
		protected function imageLoaded(event:Event):void {
			var mesh:Mesh = mLoaderInfo.mesh;
			var bitmap:Bitmap = LoaderInfo(event.target).content as Bitmap;
			var bitmapTexture:BitmapTexture = new BitmapTexture(bitmap.bitmapData);
			var textureMaterial:TextureMaterial;
			
			if (!mLoaderInfo.isMapLoaded) {
				textureMaterial = new TextureMaterial(bitmapTexture);
				var sun:int = mLoaderInfo.flags & FLAG_SUN;
				var solarSystem:int = mLoaderInfo.flags & FLAG_SOLAR_SYSTEM;
				
				if (!sun && !solarSystem) {
					textureMaterial.lightPicker = mLightPicker;
					textureMaterial.specular = 0;	
					
					var specularMethod:FresnelSpecularMethod = new FresnelSpecularMethod( true );
					specularMethod.fresnelPower = 1;
					specularMethod.normalReflectance = 0.1;
					specularMethod.shadingModel = SpecularShadingModel.PHONG;
					textureMaterial.specularMethod = specularMethod;
				}
				else if(sun) {
					textureMaterial.alphaBlending = true;
				}
				
				textureMaterial.specular = 1;	
				textureMaterial.ambient = 0.5;
				
				mesh.material = textureMaterial;				
				mLoaderInfo.isMapLoaded = true;
			}
			else if (mLoaderInfo.normalMap && !mLoaderInfo.isNormalMapLoaded) {
				textureMaterial = mesh.material as TextureMaterial;
				textureMaterial.normalMap = bitmapTexture;
				mLoaderInfo.isNormalMapLoaded = true;
			}
			else if (mLoaderInfo.ringMap && !mLoaderInfo.isRingMapLoaded) {
				textureMaterial = new TextureMaterial(bitmapTexture);
				mLoaderInfo.cosmicBody.getRing().build(textureMaterial);
				mLoaderInfo.isRingMapLoaded = true;
			}
			
			loadNext();
		}
		
		/**
		 * Zarejda sledvashtata kartinka ot opashkata
		 */
		private function loadNext():void {
			
			if (mLoaderInfo) {
				if (!mLoaderInfo.isMapLoaded) {
					mLoader.load(new URLRequest(R.TEXTURES_DIR + mLoaderInfo.map));
					return;
				}
				else if (mLoaderInfo.normalMap && !mLoaderInfo.isNormalMapLoaded) {
					mLoader.load(new URLRequest(R.TEXTURES_DIR + mLoaderInfo.normalMap));
					return;
				}
				else if (mLoaderInfo.ringMap && !mLoaderInfo.isRingMapLoaded) {
					mLoader.load(new URLRequest(R.TEXTURES_DIR + mLoaderInfo.ringMap));
					return;
				}
			}
			
			if (mLoaderInfoQueue.length > 0) {
				mLoaderInfo = mLoaderInfoQueue.shift();
				mLoader.load(new URLRequest(R.TEXTURES_DIR + mLoaderInfo.map));
				return;
			}
			
			dispatchEvent(new XmlParserEvent(mEventType, mStatus, mArray));
		}
	}
}
