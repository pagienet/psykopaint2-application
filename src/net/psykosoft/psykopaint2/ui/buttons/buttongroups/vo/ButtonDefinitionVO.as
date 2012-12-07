package net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo
{

	public class ButtonDefinitionVO
	{
		public var label:String;
		public var triggered:Function;

		public function ButtonDefinitionVO( label:String, callback:Function ) {
			super();
			this.label = label;
			this.triggered = callback;
		}
	}
}
