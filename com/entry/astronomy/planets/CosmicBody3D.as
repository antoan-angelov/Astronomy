package com.entry.astronomy.planets {
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.core.math.Vector3DUtils;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingCollisionVO;
	import away3d.core.pick.RaycastPicker;
	import away3d.core.pick.ShaderPicker;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.MouseEvent3D;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.CompositeDiffuseMethod;
	import away3d.materials.methods.CompositeSpecularMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.SpecularShadingModel;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	import away3d.primitives.LineSegment;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.tools.helpers.MeshHelper;
	
	import caurina.transitions.Tweener;
	
	import com.entry.astronomy.Main;
	import com.entry.astronomy.R;
	import com.entry.astronomy.parser.XmlParser;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	/**
	 * Triizmerno sferichno tqlo
	 * @author Antoan Angelov
	 */
	public class CosmicBody3D extends CosmicBodyBase {
				
		private var mTag:String;
		private var mMap:String;
		private var mNormalMap:String;
		private var mSegmentsW:int;
		private var mSegmentsH:int;
		private var mRotationVel:Number;
		private var mRightAsc:Number;
		private var mDecl:Number
		private var mProjectionPlane:ObjectContainer3D;
		private var mAtmosphereDiffuseMethod:BasicDiffuseMethod;
		
		private var mOrbit:Orbit;
		private var mPlanet:Mesh;
		private var mAtmosphere:Mesh;
		private var mMoons:Vector.<CosmicBody3D>;
		private var mMoonGroup:ObjectContainer3D;
		private var mRing:Ring;
		private var mPlanetRingGroup:ObjectContainer3D;
		private var mMainCont:ObjectContainer3D;
		
		public function CosmicBody3D(context:Main, world:View3D, type:int, tag:String, name:String, id:String, map:String, normalMap:String, 
			radius:Number, segmentsW:int, segmentsH:int, rotationSpeed:Number, rightAsc:Number = 0, decl:Number = 0) {
			
			super(context, world, name, id, radius, type);
			
			this.name = name;
			this.mTag = tag;
			this.mMap = map;
			this.mNormalMap = normalMap;
			this.mSegmentsW = segmentsW;
			this.mSegmentsH = segmentsH;
			this.mRotationVel = rotationSpeed;
			this.mRightAsc = rightAsc;
			this.mDecl = decl;
		}
		
		public function init():void {
			
			mMainCont = new ObjectContainer3D();
			addChild(mMainCont);
			
			mPlanetRingGroup = new ObjectContainer3D();
			mPlanetRingGroup.name = name+" planetRingGroup";
			mMainCont.addChild(mPlanetRingGroup);

			mPlanet = new Mesh(new SphereGeometry(mRadius, mSegmentsW, mSegmentsH));
			mPlanet.pickingCollider = PickingColliderType.AUTO_BEST_HIT;
			mPlanet.name = name+" planetSphere";
			mPlanetRingGroup.addChild(mPlanet);
			
			mPlanet.mouseEnabled = true;
			mPlanetRingGroup.mouseChildren = false;
			mPlanetRingGroup.addEventListener(MouseEvent3D.MOUSE_OVER, eBodyMouseOver);
			mPlanetRingGroup.addEventListener(MouseEvent3D.MOUSE_OUT, eBodyMouseOut);
			mPlanetRingGroup.addEventListener(MouseEvent3D.MOUSE_DOWN, eBodyMouseDown);
			mPlanetRingGroup.addEventListener(MouseEvent3D.MOUSE_UP, eBodyMouseUp);
			
			setNorthPoleOrientation();
			
			if (R.DEBUG_MODE) {
				drawDebugAxes();
			}
		}
		
		/**
		 * Dobavqme luna
		 * @param moon
		 */
		public function addMoon(moon:CosmicBody3D):void {
			if (!mMoons) {
				mMoonGroup = new ObjectContainer3D();
				addChild(mMoonGroup);
				mMoons = new Vector.<CosmicBody3D>();
			}
			
			moon.name = name+" moon";
			mMoons.push(moon);
			mMoonGroup.addChild(moon);
		}

		public override function update():void {
			if (mRotationVel)
				mPlanet.yaw(mRotationVel);
						
			super.update();
		}
		
		protected override function check(entity:Entity):Boolean {
			// ako ucelenoto tqlo ne e direkten naslednik na scenata, mMainCont, mPlanetRingGroup i prysten, ako ima takyv
			return (!mScene.contains(entity) && !mMainCont.contains(entity) && !mPlanetRingGroup.contains(entity) 
				&& !(mRing && mRing.contains(entity)));
		}
		
		/**
		 * Nastroiva orientaciqta na severniq polius na planetata
		 */
		private function setNorthPoleOrientation():void {
			if (!mDecl && !mRightAsc)
				return;
			
			mPlanetRingGroup.rotationX = 90 - mDecl;
			mPlanetRingGroup.rotationY = 180 - mRightAsc;
			mPlanetRingGroup.rotationZ = -R.TILT_EARTH;
		}
		
		/**
		 * Dviji planetata po orbitata i
		 */
		public override function moveAlongOrbit():void {
			if (mOrbit)
				mOrbit.moveAlongOrbit();
		}
		
		/**
		 * V DEBUG rejim chertae koordinatnite osi na trite koordinata (X, Y, Z)
		 */
		private function drawDebugAxes():void {
			var set:SegmentSet = new SegmentSet();
			var axisLen:Number = mRadius * R.DEBUG_AXIS_FACTOR;
			v.setTo(0, 0, 0);
			set.addSegment(new LineSegment(v, new Vector3D(axisLen, 0, 0), 0x0000FF, 0x0000FF));
			set.addSegment(new LineSegment(v, new Vector3D(0, axisLen, 0), 0x00FF00, 0x00FF00));
			set.addSegment(new LineSegment(v, new Vector3D(0, 0, -axisLen), 0xFF0000, 0xFF0000));
			set.rotationX = mPlanetRingGroup.rotationX;
			set.rotationY = mPlanetRingGroup.rotationY;
			set.rotationZ = mPlanetRingGroup.rotationZ;
			set.name = name+" debugAxes";
			addChild(set);
		}
		
		public override function toString():String {
			return "[" + mTag + " " + XmlParser.ATTRIBUTE_NAME + "=" + mName + ", " + XmlParser.ATTRIBUTE_MAP + "=" + mMap + ", " +
				XmlParser.ATTRIBUTE_RADIUS + "=" + mRadius + ", " + XmlParser.ATTRIBUTE_SEGMENTS_W + "=" + mSegmentsW + ", " + XmlParser.
				ATTRIBUTE_SEGMENTS_H + "=" + mSegmentsH + "]";
		}
		
		/*
		 ************************ GETTERS & SETTERS ************************
		*/
		
		public function getMoons():Vector.<CosmicBody3D> {
			return mMoons;
		}
		
		public function getPlanet():Mesh {
			return mPlanet;
		}
		
		public function getOrbit():Orbit {
			return mOrbit;
		}
		
		public function setOrbit(orbit:Orbit):void {
			mOrbit = orbit;
			mOrbit.name = name+" orbit";
			mOrbit.getCenterBody().addChild(mOrbit);
		}
		
		public override function isMovable():Boolean {
			return mOrbit != null;
		}
		
		public function setRing(ring:Ring):void {
			mRing = ring;
			mRing.name = name+" ring";
			mPlanetRingGroup.addChild(mRing);
		}
		
		public function getRing():Ring {
			return mRing;
		}
	}
}
