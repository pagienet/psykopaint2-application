package net.psykosoft.psykopaint2.app.commands
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.StateModel;

	public class ChangeStateCommand
	{
		[Inject]
		public var newState:StateVO;

		[Inject]
		public var stateModel:StateModel;

		public function execute():void {
			trace( this, "new state: " + newState.name );
			stateModel.currentState = newState;
		}
	}
}
