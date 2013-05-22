package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingCommand;
	import net.psykosoft.psykopaint2.core.models.CrStateModel;
	import net.psykosoft.psykopaint2.core.models.CrStateType;

	public class CrChangeStateCommand extends BsTracingCommand
	{
		[Inject]
		public var newState:String;

		[Inject]
		public var stateModel:CrStateModel;

		override public function execute():void {
			super.execute();
			if( newState == CrStateType.STATE_PREVIOUS ) {
				stateModel.returnToPreviousState();
			}
			else {
				stateModel.currentState = newState;
			}
		}
	}
}
