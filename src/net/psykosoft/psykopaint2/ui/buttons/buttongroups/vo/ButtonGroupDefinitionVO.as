package net.psykosoft.psykopaint2.ui.buttons.buttongroups.vo
{

	public class ButtonGroupDefinitionVO
	{
		public var buttonVOArray:Array;

		public function ButtonGroupDefinitionVO() {
			super();
		}

		public function addButtonDefinition( buttonVO:ButtonDefinitionVO ):void {
			if( !buttonVOArray ) buttonVOArray = [];
			buttonVOArray.push( buttonVO );
		}
	}
}
