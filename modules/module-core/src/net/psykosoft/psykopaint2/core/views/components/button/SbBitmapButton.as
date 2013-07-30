package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

	public class SbBitmapButton extends NavigationButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;
		public var pins:Sprite;

		public function SbBitmapButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			super.setPins( pins );
			label.visible = false;
		}

		override protected function adjustBitmap():void {
			// TODO: might want to maintain aspect ratio and mask
			_iconBitmap.width = 256 * 0.5;
			_iconBitmap.height = 192 * 0.5;
			super.adjustBitmap();
		}

		override protected function updateSelected():void {
			var frame:uint = _selected + 1;
			_pin1.gotoAndStop( frame );
			_pin2.gotoAndStop( frame );
		}
	}
}
