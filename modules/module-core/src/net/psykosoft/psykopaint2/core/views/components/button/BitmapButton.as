package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

	public class BitmapButton extends NavigationButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;
		public var pin:MovieClip;

		private var _pin:MovieClip;

		public function BitmapButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			setPin();
			label.visible = false;
		}

		private function setPin():void {
			_pin = pin;
			_pin.stop();
			randomizePinsAndRotation();
		}

		private function randomizePinsAndRotation():void {
			_icon.rotation = 4 * Math.random() - 2;
		}

		override protected function adjustBitmap():void {
			// TODO: might want to maintain aspect ratio and mask
			_iconBitmap.width = 256 * 0.5;
			_iconBitmap.height = 192 * 0.5;
			super.adjustBitmap();
		}

		override protected function updateSelected():void {
			var frame:uint = _selected + 1;
			_pin.gotoAndStop( frame );
		}
	}
}
