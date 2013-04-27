package net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo
{

	import starling.textures.Texture;

	public class ButtonDefinitionVO
	{
		public var label:String;
		public var texture:Texture;
		public var isEnabled:Boolean;
		public var triggered:Function;

		public function ButtonDefinitionVO( texture:Texture, label:String, callback:Function, isEnabled:Boolean = true ) {
			super();
			this.texture = texture;
			this.label = label;
			this.triggered = callback;
			this.isEnabled = isEnabled;
		}
	}
}
