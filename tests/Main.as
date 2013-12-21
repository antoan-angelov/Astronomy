package {
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Main extends Sprite {
		
		private var spr:Sprite;
		private var min:Number, max:Number, foci:Number;
		private var p:Sprite, b:Sprite;
		private var ang:Number;
		
		public function Main() {
			
			//drawingEllipses();
			
			calculatingTrueAnomalies();
		}
		
		private function calculatingTrueAnomalies():void {
			
			trace("Mercury: ", calcTrueAnomaly(174.796, 0.205630));
			trace("Venus: ", calcTrueAnomaly(50.115, 0.006756));
			trace("Earth: ", calcTrueAnomaly(357.517, 0.01671123));
			trace("Mars", calcTrueAnomaly(19.356, 0.093315));
			trace("Jupiter: ", calcTrueAnomaly(18.818, 0.048775));
			trace("Saturn: ", calcTrueAnomaly(320.346, 0.055723));
			trace("Uranus: ", calcTrueAnomaly(142.955, 0.044405));
			trace("Neptune: ", calcTrueAnomaly(267.767, 0.011214269));
			trace("Pluto: ", calcTrueAnomaly(14.860, 0.244671664));
			trace("Moon", calcTrueAnomaly(357.517, 0.01671123));
		}
		
		private function calcTrueAnomaly(M:Number, e:Number):String {
			var v:Number;
			
			/*
			 * 	v is true anomaly
				M is mean anomaly
				e is eccentricity
				pi is 3.14159...
			*/
			
			v = M + 180/Math.PI * ( (2 * e - Math.pow(e, 3/4)) * Math.sin(M) 
				+ 5/4 * Math.pow(e, 2) * Math.sin(2*M)
				+ 13/12 * Math.pow(e, 3) * Math.sin(3*M) );
			
			return v.toFixed(3);
		}
		
		private function drawingEllipses():void {
			ang = 0;
			
			spr = new Sprite();
			spr.x = 200;
			spr.y = 100;
			addChild(spr);
			
			p = new Sprite();
			p.graphics.beginFill(0xFF0000);
			p.graphics.drawCircle(0, 0, 10);
			p.graphics.endFill();
			spr.addChild(p);
			
			b = new Sprite();
			b.graphics.beginFill(0xFF);
			b.graphics.drawCircle(0, 0, 10);
			b.graphics.endFill();
			spr.addChild(b);
			
			min = 100;
			max = 150;
			
			drawEllipse(min, max, 5);
			
			//spr.scaleX = spr.scaleY = 0.25;
			
			//placeBodyAtAngle(40);
			addEventListener(Event.ENTER_FRAME, update);
		}		
		
		
		protected function update(event:Event):void {
			placeBodyAtAngle(ang);
		}
		
		private function placeBodyAtAngle(angle:Number):void {
			
			var rad:Number = angle*Math.PI/180;
			
			b.x = p.x;
			b.y = p.y;
			p.x = max*Math.cos(rad);
			p.y = min*Math.sin(rad);
			
			var s:Number = 200;
			
			var dx:Number = foci+p.x, dy:Number = p.y, d:Number = Math.sqrt(dx*dx+dy*dy);
			var arctan:Number = Math.atan(2*s/(d*d));
			
			ang += arctan*180/Math.PI;		
		}
		
		private function drawEllipse(rx:Number, ry:Number, step:Number):void {
			var g:Graphics = spr.graphics;
			var px:Number = 0;
			var py:Number = 0;

			rx = min;
			ry = max;
			
			g.moveTo(px, py+rx);
			g.lineStyle(1, 0);
			
			for(var i:int = step; i<360; i += step) {
				var rad:Number = i*Math.PI/180;
				g.lineTo(px+ry*Math.sin(rad), py+rx*Math.cos(rad));
			}
			
			g.lineTo(px, py+rx);			
			
			foci = Math.sqrt(max*max-min*min);
			g.beginFill(0xFF0000);
			g.lineStyle(0);
			g.drawCircle(-foci, 0, 5);
			g.drawCircle(foci, 0, 5);
			g.endFill();
		}
	}
}
