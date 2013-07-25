package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.PsykoButton;

	public class SbRightButton extends PsykoButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;

		public function SbRightButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
		}
	}
}
