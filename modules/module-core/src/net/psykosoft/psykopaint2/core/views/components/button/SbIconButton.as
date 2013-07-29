package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.SelectableButton;

	public class SbIconButton extends SelectableButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;
		public var pins:Sprite;

		public function SbIconButton() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
			super.setPins( pins );
		}
	}
}