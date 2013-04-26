package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;

	public class UpdateAppStateFromActivatedDrawingCoreModuleCommand
	{
		[Inject]
		public var moduleActivationVO:ModuleActivationVO;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		public function execute():void {

			var newState:StateVO;

			switch( moduleActivationVO.activatedModuleType ) {

				case ModuleType.PAINT:
					newState = new StateVO( ApplicationStateType.PAINTING_SELECT_BRUSH );
					break;

				case ModuleType.CROP:
					newState = new StateVO( ApplicationStateType.PAINTING_CROP_IMAGE );
					break;

				case ModuleType.COLOR_STYLE:
					newState = new StateVO( ApplicationStateType.PAINTING_SELECT_COLORS );
					break;

				case ModuleType.SMEAR:
					throw new Error( "Don't know what to do with this module..." );
					break;

				// TODO: there are still application states not associated here.

			}

			trace( this, "drawing core module activated: " + moduleActivationVO.activatedModuleType + " ------------------------------------------" );
			trace( this, "-> triggers application state: " + newState.name );
			trace( this, "-> previously active module: " + moduleActivationVO.deactivatedModuleType );
			trace( this, "-> next active module: " + moduleActivationVO.concatenatingModuleType );

			requestStateChangeSignal.dispatch( newState );

		}
	}
}
