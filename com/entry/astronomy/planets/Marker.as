package com.entry.astronomy.planets {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Opisva nadpisa s imeto na planetata
	 * @author Antoan Angelov
	 */
	public class Marker extends Sprite {
		
		var mCosmicBody:CosmicBodyBase;
		var mLabel:TextField;
		var mCont:Sprite;
		var rect:Rectangle;
		var point:Point;
		
		public function Marker(cosmicBody:CosmicBodyBase, text:String) {
			super();
			
			this.mCosmicBody = cosmicBody;
			
			visible = false;
			rect = new Rectangle();
			point = new Point();
			
			mCont = new Sprite();
			addChild(mCont);
			var radius:Number = 5;
			var inclLineLen:Number = 15;
			var horLineLen:Number = 15;
			
			// Risuvame dvete cherti i krygcheto, koito oboznachavat za koq planeta se otnasq nadpisa
			mCont.graphics.beginFill(0xFFFFFF);
			mCont.graphics.drawCircle(0, 0, radius);
			mCont.graphics.endFill();
			
			var k = Math.SQRT2 * 0.5;
			mCont.graphics.lineStyle(2, 0xFFFFFF);
			mCont.graphics.moveTo(k*radius, k*radius);
			mCont.graphics.lineTo(k*inclLineLen, k*inclLineLen);
			mCont.graphics.lineTo(k*inclLineLen+horLineLen, k*inclLineLen);
			
			var outline:GlowFilter = new GlowFilter(0xFF000000, 0.4, 4, 4, 10);
			mCont.filters = [outline];
			
			// Stil na nadpisa (shrift, golemina, cvqt)
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Segoe UI";
			textFormat.size = 15;
			textFormat.color = 0xFFFFFF;
			
			// Dobavqme i samiq nadpis
			mLabel = new TextField();
			mLabel.embedFonts = true;
			mLabel.defaultTextFormat = textFormat;
			mLabel.text = text;
			mLabel.autoSize = TextFieldAutoSize.LEFT;
			mLabel.backgroundColor = 0xFF0000;
			mLabel.antiAliasType = "advanced";
			mLabel.selectable = false;
			addChild(mLabel);
			
			var textOutline:GlowFilter = new GlowFilter(0xFF000000, 1, 4, 4, 10);
			mLabel.filters = [textOutline];
			
			mLabel.x = k*inclLineLen+horLineLen+5;
			mLabel.y = k*inclLineLen-10;
		}
	}
}
