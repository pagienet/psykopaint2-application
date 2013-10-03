package net.psykosoft.psykopaint2.core.views.components.button
{

	import flash.display.MovieClip;
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.components.BackgroundLabel;

	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

	public class IconButtonAlt extends NavigationButton
	{
		// Declared in Flash.
		public var label:Sprite;
		public var icon:MovieClip;

		public function IconButtonAlt() {
			super();
			super.setLabel( label );
			super.setIcon( icon );
		}
	}
}
