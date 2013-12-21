package com.entry.astronomy.planets {
	import away3d.containers.View3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	
	import com.entry.astronomy.Main;
	import com.entry.astronomy.parser.XmlParser;
	
	/**
	 * Plosko tqlo s tekstura
	 * @author Antoan Angelov
	 */
	public class CosmicBody2D extends CosmicBodyBase {
		
		private var mPlane:Mesh;
		
		public function CosmicBody2D(context:Main, world:View3D, name:String, id:String, radius:Number, type:int) {
			super(context, world, name, id, radius, type);
		}
		
		/**
		 * Dobavqme 3D interpretaciqta na ploskoto tqlo
		 * @param plane
		 */
		public function addPlane(plane:Mesh):void {
			mPlane = plane;
			mPlane.pickingCollider = PickingColliderType.AUTO_BEST_HIT;
			addChild(mPlane);
			
			mPlane.mouseEnabled = true;
			mPlane.addEventListener(MouseEvent3D.MOUSE_OVER, eBodyMouseOver);
			mPlane.addEventListener(MouseEvent3D.MOUSE_OUT, eBodyMouseOut); 
			mPlane.addEventListener(MouseEvent3D.MOUSE_DOWN, eBodyMouseDown);
			mPlane.addEventListener(MouseEvent3D.MOUSE_UP, eBodyMouseUp);
		}
		
		public override function update():void {
			if(mPlane) {
				mPlane.rotationX = mWorld.camera.rotationX-90;
				mPlane.rotationY = mWorld.camera.rotationY;
				mPlane.rotationZ = mWorld.camera.rotationZ;
			}
			
			super.update();
		}
		
		protected override function check(entity:Entity):Boolean {
			return (entity != mPlane);
		}
		
		public override function toString():String {
			return "[" + XmlParser.TAG_SUN + " " + XmlParser.ATTRIBUTE_NAME + "=" + mName + "]";
		}
	}
}
