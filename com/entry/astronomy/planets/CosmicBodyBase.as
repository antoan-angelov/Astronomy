package com.entry.astronomy.planets {
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.pick.PickingCollisionVO;
	import away3d.core.pick.ShaderPicker;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.TextureMaterial;
	
	import caurina.transitions.Tweener;
	
	import com.entry.astronomy.Main;
	import com.entry.astronomy.events.PlanetMouseEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	
	/**
	 * Bazov klas na kosmicheskite obekti
	 * @author Antoan Angelov
	 */
	public class CosmicBodyBase extends ObjectContainer3D {
		
		public static const TYPE_PLANET:int = 1;
		public static const TYPE_MOON:int = 2;
		public static const TYPE_SUN:int = 3;
		
		/** Nai-malkoto razstoqnie, na koeto trqbva da sme ot luna, za da se pokaje nadpisa s imeto i */
		public static const MOON_SHOW_DIST:Number = 1800;
		
		protected var mContext:Main;
		protected var mWorld:View3D;		
		protected var mScene:Scene3D;
		
		protected var mName:String;
		protected var mId:String;
		protected var mRadius:Number;
		protected var mType:int;
		
		private var mMarkerCont:Sprite;
		
		protected var temp:Marker;		
		protected var v:Vector3D;
		private var mMouseDownObject:ObjectContainer3D;
		
		private static var mColorTransformOnMouseOver:ColorTransform = new ColorTransform(2, 2, 2);
		private static var mColorTransformOnMouseOut:ColorTransform = new ColorTransform(1, 1, 1);
		public var selectable:Boolean;		
		
		public function CosmicBodyBase(context:Main, world:View3D, name:String, id:String, radius:Number, type:int) {
			
			this.mContext = context;
			this.mWorld = world;
			this.mScene = world.scene;
			this.mName = name;
			this.mId = id;
			this.mRadius = radius;
			this.mType = type;
			
			selectable = true;
			
			v = new Vector3D();			
			temp = new Marker(this, mName);
		}
		
		/**
		 * Izpylnqva se pri natiskane s mishka na planetata. 
		 */
		protected function eBodyMouseDown(e:MouseEvent3D):void {
			mMouseDownObject = e.object;
			dispatchEvent(new PlanetMouseEvent(PlanetMouseEvent.DOWN, this));
		}
		
		/**
		 * Izpylnqva se pri otpuskane na kopcheto na mishkata ot planetata. Ako e syshtata planeta,
		 * koqto sme natisnali s mishkata, uvedomqva vsichkite slushateli na sybitieto.
		 */
		protected function eBodyMouseUp(e:MouseEvent3D):void {

			if(e.object == mMouseDownObject) {
				var mesh:Mesh = e.object as Mesh;
				var textureMaterial:TextureMaterial = mesh.material as TextureMaterial;
				textureMaterial.colorTransform = mColorTransformOnMouseOut;
				dispatchEvent(new PlanetMouseEvent(PlanetMouseEvent.CLICK, this));
			}
			
			dispatchEvent(new PlanetMouseEvent(PlanetMouseEvent.UP, this));
			mMouseDownObject = null;
		}
			
		/**
		 * Mishkata minava nad planetata. V rezultat na tova, teksturata stava po-svetla.
		 */
		protected function eBodyMouseOver(e:MouseEvent3D):void {
			if(selectable) {
				var mesh:Mesh = e.object as Mesh;
				var textureMaterial:TextureMaterial = mesh.material as TextureMaterial;
				textureMaterial.colorTransform = mColorTransformOnMouseOver;
			}

			dispatchEvent(new PlanetMouseEvent(PlanetMouseEvent.OVER, this));
		}
		
		/**
		 * Mishkata izliza izvyn planetata. Teksturata vyzvryshta originalnata si qrkost.
		 */
		protected function eBodyMouseOut(e:MouseEvent3D):void {	
			if(selectable) {
				var mesh:Mesh = e.object as Mesh;
				var textureMaterial:TextureMaterial = mesh.material as TextureMaterial;
				textureMaterial.colorTransform = mColorTransformOnMouseOut;
			}

			dispatchEvent(new PlanetMouseEvent(PlanetMouseEvent.OUT, this));
		}		
		
		public function moveAlongOrbit():void {
		}
		
		public function update():void {
			handleMarkers();
		}
		
		/**
		 * Pokazva i skriva nadpisite na planetite, kogato e nalojitelno.
		 */
		protected function handleMarkers() {
			if(temp) {				
				v.setTo(0, 0, 0);
				var worldPos:Vector3D = getVerticeWorldPosition();				
				var projPos:Vector3D = mWorld.project(worldPos);
				var showMoonMarker:Boolean = true;
				
				// nadpisite za lunite ne se pokazvat, dokato ne se namirame dostatychno blizo do tqh
				if(mType == TYPE_MOON) {
					var distFromCam:Number = Vector3D.distance(scenePosition, mWorld.camera.position);
					
					if(distFromCam > MOON_SHOW_DIST)
						showMoonMarker = false;
				}
				
				if(projPos.z > 0) {
					
					if(showMoonMarker) {
						/* Izprashtame lych kym poziciqta na planetata - ako lycha se udari v tqlo, razlichno ot tazi planeta,
						skrivame nadpisa s imeto na planetata.*/
						var picker:ShaderPicker = new ShaderPicker();
						var VO:PickingCollisionVO = picker.getViewCollision(projPos.x, projPos.y, mWorld);
						
						var entity:Entity = (VO ? VO.entity : null);					
						
						/* funkciqta check() se nasledqva v CosmicBody2D i CosmicBody3D - izpolzvame q za dopylnitelna proverka, v sluchai che
						lycha udrq prystena na planetata - bez funkciqta, markera shte se skriva bez vidimo da ima prichina.
						*/
						if(entity && check(entity))					
							hideMarkerIfCan(temp);
						else 
							showMarkerIfCan(temp);
					}
					else 
						hideMarkerIfCan(temp);				
					
					temp.x = projPos.x;
					temp.y = projPos.y;
				}
				else if(temp.visible)
					temp.visible = false;			
			}
		}
		
		/**
		 * Pravi kratka animaciq, s koqto pokazva nadpisa na planetata
		 */
		private function showMarkerIfCan(marker:Marker):void {
			if(!marker.visible) {
				marker.visible = true;
				marker.alpha = 0;
				Tweener.addTween(marker, {alpha:1, time:1});
			}
		}
		
		/**
		 * Pravi kratka animaciq, s koqto skriva nadpisa na planetata
		 */
		private function hideMarkerIfCan(marker:Marker) {
			if(marker.visible && !Tweener.isTweening(marker)) {
				marker.alpha = 1;
				Tweener.addTween(marker, {alpha:0, time:1, onComplete:function() { marker.visible = false; }});
			}
		}		
		
		private function getVerticeWorldPosition():Vector3D {
			v = sceneTransform.transformVector(v);			
			return v; 
		}
		
		protected function check(entity:Entity):Boolean {
			return false;
		}
		
		/*
		  ************************ GETTERS & SETTERS ************************
		*/
		
		public function getMarker():Marker {
			return temp;
		}
		
		public function setMarkerCont(markerCont:Sprite):void {
			this.mMarkerCont = markerCont;
			if(temp) {
				mMarkerCont.addChild(temp);
			}
		}
		
		public function getId():String {
			return mId;
		}
		
		public function isMovable():Boolean {
			return false;
		}
		
		public function getName():String {
			return mName;
		}
		
		public function getRadius():Number {
			return mRadius;
		}
	}
}
