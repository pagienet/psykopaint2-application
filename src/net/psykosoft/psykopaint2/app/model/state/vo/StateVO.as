package net.psykosoft.psykopaint2.app.model.state.vo
{

	public class StateVO
	{
		public var name:String;

		public function StateVO( name:String ) {
			this.name = name;
		}

		public function toString():String {
			return name;
		}
	}
}
