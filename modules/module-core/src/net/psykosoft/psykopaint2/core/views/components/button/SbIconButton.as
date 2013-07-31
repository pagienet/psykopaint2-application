package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.BackgroundLabel;

	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

	public class SbIconButton extends NavigationButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;

		public function SbIconButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
		}

		override protected function updateSelected():void {
			var label:BackgroundLabel = _label as BackgroundLabel;
			label.colorizeBackground( _selected ? 0xFF0000 : 0xFFFFFF );
		}
	}
}
