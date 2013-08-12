package net.psykosoft.psykopaint2.core.views.components.label
{

	import flash.display.Sprite;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.base.ui.components.BackgroundLabel;

	public class CenterLabel extends BackgroundLabel
	{
		// Declared in Flash.
		public var textfield:TextField;
		public var background:Sprite;

		public function CenterLabel() {
			super();
			super.setBackground( background );
			super.setTextfield( textfield );
		}
	}
}
