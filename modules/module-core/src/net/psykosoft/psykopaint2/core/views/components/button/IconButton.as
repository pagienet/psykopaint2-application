package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.BackgroundLabel;

	public class IconButton extends IconButtonBase
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:IconButtonPaperFold;
		public var pinMc:Sprite;

		public function IconButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			
			var bgLabel:BackgroundLabel = _label as BackgroundLabel;

			bgLabel.rotation = Math.random()*4-2;
			bgLabel.randomizeLabelColor();
		}
		
		override public function set labelText(value:String):void{
			super.labelText = value;
			pinMc.x = label.x - label.width/2 +14;
		}
		
		override protected function updateSelected():void {
			var label:BackgroundLabel = _label as BackgroundLabel;
			//label.colorizeBackground( _selected ? 0xFF0000 : 0xFFFFFF );
			if(_selected)
				label.colorizeBackground(  /*0x00FF00*/0 );
			else 
				label.randomizeLabelColor();
		}
	}
}
