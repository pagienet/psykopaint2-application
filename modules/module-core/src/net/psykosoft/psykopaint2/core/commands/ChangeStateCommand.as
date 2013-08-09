package net.psykosoft.psykopaint2.core.commands
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	public class ChangeStateCommand extends TracingCommand
	{
		[Inject]
		public var newState:String;

		[Inject]
		public var stateModel:NavigationStateModel;

		override public function execute():void {
			super.execute();
			if( newState == NavigationStateType.PREVIOUS ) {
				stateModel.returnToPreviousState();
			}
			else {
				stateModel.currentState = newState;
			}
		}
	}
}
