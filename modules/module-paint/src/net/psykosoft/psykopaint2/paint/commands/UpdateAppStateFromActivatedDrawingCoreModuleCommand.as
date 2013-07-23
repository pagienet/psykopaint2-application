package net.psykosoft.psykopaint2.paint.commands
{

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	public class UpdateAppStateFromActivatedDrawingCoreModuleCommand extends TracingCommand
	{
		[Inject]
		public var moduleActivationVO:ModuleActivationVO;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var stateModel:StateModel;

		override public function execute():void {
			super.execute();

			var newState:String;

			trace( this, "prev: " + moduleActivationVO.deactivatedModuleType );

			switch( moduleActivationVO.activatedModuleType ) {

				case ModuleType.PAINT:

					if( stateModel.currentState == StateType.IDLE ) {
						newState = StateType.PAINT;
					}
					else {
						// Animate to paint.
						var wasInAPaintState:Boolean = stateModel.currentState.indexOf( StateType.PAINT );
						if( !wasInAPaintState ) newState = StateType.PREPARE_FOR_PAINT_MODE;
					}

					break;

				case ModuleType.CROP:
					newState = StateType.CROP;
					break;

				case ModuleType.COLOR_STYLE:
					newState = StateType.COLOR_STYLE;
					break;

				case ModuleType.SMEAR:
					throw new Error( this + " - don't know what to do with this module..." );
					break;

				// TODO: there are still application states not associated here.

			}

			trace( this, "drawing core module activated: " + moduleActivationVO.activatedModuleType + " ------------------------------------------" );
			trace( this, "-> triggers application state: " + newState );
			trace( this, "-> previously active module: " + moduleActivationVO.deactivatedModuleType );
			trace( this, "-> next active module: " + moduleActivationVO.concatenatingModuleType );

			requestStateChangeSignal.dispatch( newState );
		}
	}
}
