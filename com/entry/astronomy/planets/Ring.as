package com.entry.astronomy.planets {
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.SubGeometry;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	
	import com.entry.astronomy.parser.XmlParser;
	
	/**
	 * Vizualna interpretaciq na prystena na planetata
	 * @author Antoan Angelov
	 */
	public class Ring extends ObjectContainer3D {
		
		private var mCosmicBody:CosmicBody3D;
		
		private var mRadius:Number;
		private var mNumMeshes:int;
		private var mThickness:Number;
		
		public function Ring(cosmicBody:CosmicBody3D, radius:Number, numMeshes:int, thickness:Number) {
			this.mCosmicBody = cosmicBody;
			this.mRadius = radius;
			this.mNumMeshes = numMeshes;
			this.mThickness = thickness;
		}
		
		public function init():void {
			mCosmicBody.setRing(this);
		}
		
		/**
		 * Syzdava dostatychno na broi triizmerni trapci i gi namestva precizno, za da se poluchi prysten.
		 * @param textureMaterial
		 */
		public function build(textureMaterial:TextureMaterial):void {
			
			// pyrvo pravim nujnite izchisleniq otnosno razmerite na trapeca
			
			var innerRadius:Number = mRadius, outerRadius:Number = innerRadius+mThickness;
			var angPerMeshDeg:Number = (360 / mNumMeshes);
			var angPerMeshRad:Number = angPerMeshDeg / 180 * Math.PI;
			var halfPi:Number = Math.PI/2;
			
			var t:Number = Math.sqrt(2*(1-Math.cos(angPerMeshRad)));
			var smallBase:Number = innerRadius*t;
			var bigBase:Number = outerRadius*t;
			var dx:Number = (bigBase-smallBase)*0.5, d:Number = outerRadius-innerRadius, h:Number = Math.sqrt(d*d-dx*dx);
			var w:Number = bigBase;
			
			textureMaterial.bothSides = true;
			textureMaterial.alphaBlending = true;
			textureMaterial.smooth = true;
			textureMaterial.animateUVs = true;	
			var xx:Number = (innerRadius*h)/d;
			
			var planeGeo:PlaneGeometry = new PlaneGeometry(w, h, 1, 1);
			var a:SubGeometry = planeGeo.subGeometries[0];
			a.vertexData[0]+=dx;
			a.vertexData[3]-=dx;
			for(var i:int = 2; i<a.vertexData.length; i+=3)
				a.vertexData[i] += h*0.5+xx;
			
			var currentAng:Number = 0;
			
			// Sled kato imame nujnata informaciq, pravim dostatychno na broi trapci i gi dopirame po bedrata im	
			for(i=0; i<mNumMeshes; i++) {
				var temp:Mesh = new Mesh(planeGeo, textureMaterial);
				temp.name = mCosmicBody.name+" ringMesh";
				temp.pickingCollider = PickingColliderType.AS3_BEST_HIT;
				temp.subMeshes[0].uvRotation = halfPi;									
				addChild(temp);
				temp.rotationY = currentAng;
				currentAng += angPerMeshDeg;
			}
		}
		
		public override function toString():String {
			return mCosmicBody + " > [" + XmlParser.TAG_RING + " " + XmlParser.ATTRIBUTE_RADIUS + "=" + mRadius + ", "
				+ XmlParser.ATTRIBUTE_NUM_MESHES + "=" + mNumMeshes + ", "	+ XmlParser.ATTRIBUTE_THICKNESS + "=" + mThickness + "]";
		}
	}
}
