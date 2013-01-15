package net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo
{

	public class ButtonDefinitionVO
	{
		public var label:String;
		public var isEnabled:Boolean;
		public var triggered:Function;

		public function ButtonDefinitionVO( label:String, callback:Function, isEnabled:Boolean = true ) {
			super();
			this.label = label;
			this.triggered = callback;
			this.isEnabled = isEnabled;
		}
	}
}
