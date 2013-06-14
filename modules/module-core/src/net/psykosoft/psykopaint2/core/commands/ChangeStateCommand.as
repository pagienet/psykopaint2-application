package net.psykosoft.psykopaint2.core.commands
{

	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	public class ChangeStateCommand extends TracingCommand
	{
		[Inject]
		public var newState:String;

		[Inject]
		public var stateModel:StateModel;

		override public function execute():void {
			super.execute();
			if( newState == StateType.PREVIOUS ) {
				stateModel.returnToPreviousState();
			}
			else {
				stateModel.currentState = newState;
			}
		}
	}
}
