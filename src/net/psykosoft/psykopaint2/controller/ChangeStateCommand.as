package net.psykosoft.psykopaint2.controller
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.StateModel;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;

	public class ChangeStateCommand
	{
		[Inject]
		public var newState:StateVO;

		[Inject]
		public var stateModel:StateModel;

		public function execute():void {

			Cc.info( this, "executed" );

			stateModel.state = newState;

		}
	}
}
