package com.entry.astronomy.lessons {
	
	import caurina.transitions.Tweener;
	
	import com.entry.astronomy.Main;
	import com.entry.astronomy.R;
	import com.entry.astronomy.visuals.FixTextArea;
	import com.entry.astronomy.visuals.buttons.LessonItemBtn;
	import com.entry.astronomy.wrappers.ImageWrapper;
	import com.entry.astronomy.wrappers.LessonWrapper;
	
	import fl.containers.UILoader;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Sydyrja metodi i informaciq za urocite
	 * @author Antoan Angelov
	 */
	public class Lesson {
		
		private var mContext:Main;
		private var mGalleryCont:Sprite;
		private var mLessonWrapper:LessonWrapper;
		private var currentIndex:int;
		private var maxIndex:int;
		private var mGallery:MovieClip;
		private var ta:FixTextArea;
		
		public function Lesson(context:Main, galleryCont:Sprite) {
			this.mContext = context;
			this.mGalleryCont = galleryCont;
		}
		
		/**
		 * 
		 * @param lesson Vizualnata interpretaciq na uroka
		 * @param lessons Vsichki uroci
		 * @param lessonWrapper Informaciq za tekushtiq urok
		 * @param css CSS, koito da se izpolzva kym uroka (toi e v HTML format)
		 */
		public function init(lesson:MovieClip, lessons:Array, lessonWrapper:LessonWrapper, css:StyleSheet):void {
			
			this.mLessonWrapper = lessonWrapper;
			currentIndex = 0;
			
			var title:TextField = lesson.getChildByName("title") as TextField;
			title.text = lessonWrapper.getTitle();
			
			mGallery = lesson.getChildByName("gallery") as MovieClip;
			
			var obj:DisplayObject = lesson.getChildByName("text_area");
			if(obj)
				lesson.removeChild(obj);
			
			// tuk se pokazva celiq urok
			ta = new FixTextArea();
			ta.name = "text_area"
			ta.textField.styleSheet = css;
			ta.textField.htmlText = lessonWrapper.getContent();
			lesson.addChild(ta);
			ta.x = -295;
			ta.y = -290;
			ta.width = 585;
			ta.height = 440;
			ta.textField.embedFonts = true;
						
			var px:Number = -500;
			var py:Number = -303;
			
			// dobavqme kopchetata vlqvo za drugite uroci
			for(var i:int = 0; i<lessons.length; i++) {
				var btn:LessonItemBtn = new LessonItemBtn();
				var tf:TextField = btn.getChildByName("tf") as TextField;
				tf.text = lessons[i].getTitle();
				btn.buttonMode = true;
				btn.mouseChildren = false;
				btn.x = px;
				btn.y = py;
				py += 43;
				lesson.addChild(btn);
			}
			
			var images:Vector.<ImageWrapper> = mLessonWrapper.getImages();
			maxIndex = int(images.length/4);
			
			for(i = 0; i<4; i++) {
				var loader:UILoader = mGallery.getChildByName("loader"+(i+1)) as UILoader; 
				loader.mouseChildren = false;
				loader.mouseEnabled = true;
				loader.buttonMode = true;
			}
			
			var left:MovieClip = mGallery.getChildByName("left_arrow") as MovieClip;
			var right:MovieClip = mGallery.getChildByName("right_arrow") as MovieClip;
			
			if(images.length > 4) {				
				left.alpha = 1;
				left.mouseEnabled = true;
				left.buttonMode = true;
				right.alpha = 1;
				right.mouseEnabled = true;
				right.buttonMode = true;
			}
			else {
				left.alpha = 0;
				left.mouseEnabled = false;
				left.buttonMode = false;
				right.alpha = 0;
				right.mouseEnabled = false;
				right.buttonMode = false;
			}
			
			loadImages();
		}
		
		
		/**
		 * Zarejda sledvashtite 4 kartinki ot galeriqta kym tekushtiq urok
		 */
		public function loadNextImages():void {
			
			var images:Vector.<ImageWrapper> = mLessonWrapper.getImages();
			
			if(images.length <= 4)
				return;
			
			if(currentIndex+1 <= maxIndex)
				currentIndex++;
			else 
				currentIndex = 0;
			
			loadImages();
		}
		
		/**
		 * Zarejda predishnite 4 kartinki ot galeriqta kym tekushtiq urok
		 */
		public function loadPrevImages():void {
			
			var images:Vector.<ImageWrapper> = mLessonWrapper.getImages();
			
			if(images.length <= 4)
				return;
			
			if(currentIndex-1 >= 0)
				currentIndex--;
			else 
				currentIndex = maxIndex;
			
			loadImages();
		}
		
		/**
		 * Zarejda 4 kartinki s index ot currentIndex do currentIndex+4
		 */
		private function loadImages():void {
			
			var images:Vector.<ImageWrapper> = mLessonWrapper.getImages();

			if(images.length - (currentIndex+1)*4 >= 0) {
				for(var i:int = 0; i<4; i++) {
					var loader:UILoader = mGallery.getChildByName("loader"+(i+1)) as UILoader; 
					loader.source = R.LESSONS_IMAGES_DIR+mLessonWrapper.getImages()[currentIndex*4+i].getSrc();
					loader.visible = true;
				}
			}
			else {
				var n:int = images.length%4;
				for(i = 0; i<n; i++) {
					loader = mGallery.getChildByName("loader"+(i+1)) as UILoader; 
					loader.source = R.LESSONS_IMAGES_DIR+mLessonWrapper.getImages()[currentIndex*4+i].getSrc(); 
					loader.visible = true;
				}
				
				for(i=n; i<4; i++) {
					loader = mGallery.getChildByName("loader"+(i+1)) as UILoader; 
					loader.visible = false;
				}
			}
		}
		
		/**
		 * Vryshta informaciq za kartinkata spored instanciqta na klasa UILoader, v koito tq se namira.
		 * @param loader
		 * @return 
		 */
		private function getImageByLoader(loader:UILoader):ImageWrapper {
			
			for(var i:int = 0; i<4; i++) {
				var l:UILoader = mGallery.getChildByName("loader"+(i+1)) as UILoader; 
								
				if(l == loader)
					break;
			}
			
			return mLessonWrapper.getImages()[int(currentIndex*4+i)];
		}
		
		/**
		 * Pokazva snimka ot galeriqta na uroka v cql razmer
		 * @param loader UILoader instanciqta, v koqto se namira snimkata
		 */
		public function viewImage(loader:UILoader):void {
			var bitmap:Bitmap = loader.content as Bitmap;
			// ugolemqvame kartinkata
			var bigBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
			bigBitmap.x = (mContext.stage.stageWidth-bigBitmap.width)*0.5;
			bigBitmap.y = (mContext.stage.stageHeight-bigBitmap.height)*0.5;
			
			// dobavqme tymen fon za kontrast
			mGalleryCont.graphics.beginFill(0x000000, 0.8);
			mGalleryCont.graphics.drawRect(0, 0, mContext.stage.stageWidth, mContext.stage.stageHeight);
			mGalleryCont.graphics.endFill();
			mGalleryCont.addChild(bigBitmap)
			mGalleryCont.mouseChildren = false;
			
			var image:ImageWrapper = getImageByLoader(loader);
			// dobavqme opisanie na kartinkata pod formata na tekstovo pole
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Segoe UI", 18, 0xFFFFFF);
			tf.embedFonts = true;
			tf.y = bigBitmap.y+bigBitmap.height;
			tf.x = 0;
			tf.width = mContext.stage.stageWidth;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.text = image.getDescr();
			tf.background = true;
			tf.backgroundColor = 0x000000;
			mGalleryCont.addChild(tf);
			mContext.addChild(mGalleryCont);
			mGalleryCont.alpha = 0;
			
			Tweener.addTween(mGalleryCont, {alpha:1, time:0.7});
		}
	}
}
