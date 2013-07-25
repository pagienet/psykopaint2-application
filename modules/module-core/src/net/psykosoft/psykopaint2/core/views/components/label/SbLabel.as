package net.psykosoft.psykopaint2.core.views.components.label
{

	import flash.text.TextField;

	import net.psykosoft.psykopaint2.base.ui.components.PsykoLabel;

	public class SbLabel extends PsykoLabel
	{
		// Declared in Flash.
		public var textfield:TextField;

		public function SbLabel() {
			super();
			super.setTextfield( textfield );
		}
	}
}
