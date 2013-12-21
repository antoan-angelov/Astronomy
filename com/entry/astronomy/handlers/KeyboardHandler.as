package com.entry.astronomy.handlers {
	import flash.events.KeyboardEvent;
	import com.entry.astronomy.Main;
	
	/**
	 * Tozi klas obrabotva sybitiqta s klaviatura. 
	 * @author Antoan Angelov
	 */
	public class KeyboardHandler {
		
		/**Instanciq na glavniq klas */
		private var mContext:Main;
		
		/**
		 * 
		 * @param context
		 */
		public function KeyboardHandler(context:Main) {
			this.mContext = context;
		}
		
		/**
		 * Izvikva se pri natiskane na klavish
		 */
		public function kDown(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 87:
				case 38:
					mContext.setUp(true);
					break;
				case 83:
				case 40:
					mContext.setDown(true);
					break;
			}
		}
		
		/**
		 * Izvikva se pri puskane na klavish
		 */
		public function kUp(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case 87:
				case 38:
					mContext.setUp(false);
					break;
				case 83:
				case 40:
					mContext.setDown(false);
					break;
				case 70:
					mContext.toggleFullscreen();
					break;
			}
		}
	}
}
