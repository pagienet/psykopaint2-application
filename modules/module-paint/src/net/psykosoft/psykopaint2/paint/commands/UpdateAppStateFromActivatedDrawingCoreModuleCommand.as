package net.psykosoft.psykopaint2.paint.commands
{

	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.models.StateModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintStateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;

	public class UpdateAppStateFromActivatedDrawingCoreModuleCommand extends TracingCommand
	{
		[Inject]
		public var moduleActivationVO:ModuleActivationVO;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var stateModel:StateModel;

		[Inject]
		public var requestPaintStateSignal : RequestPaintStateSignal;

		override public function execute():void {
			super.execute();

			var newState:String;

			trace( this, "prev: " + moduleActivationVO.deactivatedModuleType );

			switch( moduleActivationVO.activatedModuleType ) {

				case ModuleType.PAINT:

					if( moduleActivationVO.deactivatedModuleType != ModuleType.NONE ) {
						requestPaintStateSignal.dispatch();
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

			// this null-guard is to check during the refactor which states have already been refactored
			if (!newState) return;


			trace( this, "drawing core module activated: " + moduleActivationVO.activatedModuleType + " ------------------------------------------" );
			trace( this, "-> triggers application state: " + newState );
			trace( this, "-> previously active module: " + moduleActivationVO.deactivatedModuleType );
			trace( this, "-> next active module: " + moduleActivationVO.concatenatingModuleType );

			requestStateChangeSignal.dispatch( newState );
		}
	}
}
