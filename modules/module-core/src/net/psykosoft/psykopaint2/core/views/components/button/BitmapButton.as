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
		public var pins:Sprite;

		private var _pin1:MovieClip;
		private var _pin2:MovieClip;

		public function BitmapButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			setPins( pins );
			label.visible = false;
		}

		private function setPins( pins:Sprite ):void {
			_pin1 = pins.getChildByName( "pin1" ) as MovieClip;
			_pin2 = pins.getChildByName( "pin2" ) as MovieClip;
			_pin1.stop();
			_pin2.stop();
			randomizePinsAndRotation();
		}

		private function randomizePinsAndRotation():void {

			if( !pins.visible ) return;
			_pin1.visible = _pin2.visible = false;

			// Random rotation.
			_icon.rotation = 4 * Math.random() - 2;

			// Decide pin visibility depending on angle.
			if( Math.round( _icon.rotation ) == 0 ) _pin1.visible = _pin2.visible = true;
			else {
				_pin1.x = 40;
				_pin1.visible = true;
			}
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
