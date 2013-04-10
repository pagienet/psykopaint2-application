package net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo
{

	public class ButtonDefinitionVO
	{
		public var label:String;
		public var textureID:String
		public var isEnabled:Boolean;
		public var triggered:Function;

		public function ButtonDefinitionVO( textureID:String,label:String, callback:Function, isEnabled:Boolean = true ) {
			super();
			this.textureID = textureID;
			this.label = label;
			this.triggered = callback;
			this.isEnabled = isEnabled;
		}
	}
}
