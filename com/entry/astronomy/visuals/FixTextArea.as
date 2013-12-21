package com.entry.astronomy.visuals {
	
	import fl.controls.TextArea;
	
	/**
	 * TextArea s popraven byg pri polzvane na html formatirane
	 * @author Antoan Angelov
	 */
	public class FixTextArea extends TextArea {
		public function FixTextArea() {
			super();
		}
		
		override protected function drawTextFormat():void {
			if (!textField.styleSheet)
				super.drawTextFormat();
			else {
				setEmbedFont();
				if (_html)
					textField.htmlText = _savedHTML;
			}
		}
	}
}
