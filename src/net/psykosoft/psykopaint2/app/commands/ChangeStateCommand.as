package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.model.state.StateModel;
	import net.psykosoft.psykopaint2.app.model.state.vo.StateVO;

	public class ChangeStateCommand
	{
		[Inject]
		public var newState:StateVO;

		[Inject]
		public var stateModel:StateModel;

		public function execute():void {
			stateModel.currentState = newState;
		}
	}
}
