package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

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
			_pins.transform.colorTransform = _selected ? new ColorTransform( 1, 0, 0 ) : new ColorTransform();
		}
	}
}
