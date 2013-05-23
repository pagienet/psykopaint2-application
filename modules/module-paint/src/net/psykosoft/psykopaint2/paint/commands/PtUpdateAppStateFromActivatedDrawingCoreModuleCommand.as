package net.psykosoft.psykopaint2.paint.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingCommand;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.signals.requests.CrRequestStateChangeSignal;

	public class PtUpdateAppStateFromActivatedDrawingCoreModuleCommand extends BsTracingCommand
	{
		[Inject]
		public var moduleActivationVO:ModuleActivationVO;

		[Inject]
		public var requestStateChangeSignal:CrRequestStateChangeSignal;

		override public function execute():void {
			super.execute();

			var newState:String;

			switch( moduleActivationVO.activatedModuleType ) {

				case ModuleType.PAINT:
					newState = CrStateType.STATE_PAINT;
					break;

				case ModuleType.CROP:
					newState = CrStateType.STATE_CROP;
					break;

				case ModuleType.COLOR_STYLE:
					newState = CrStateType.STATE_COLOR_STYLE;
					break;

				case ModuleType.SMEAR:
					throw new Error( this + " - don't know what to do with this module..." );
					break;

				// TODO: there are still application states not associated here.

			}

			Cc.log( this, "drawing core module activated: " + moduleActivationVO.activatedModuleType + " ------------------------------------------" );
			Cc.log( this, "-> triggers application state: " + newState );
			Cc.log( this, "-> previously active module: " + moduleActivationVO.deactivatedModuleType );
			Cc.log( this, "-> next active module: " + moduleActivationVO.concatenatingModuleType );

			requestStateChangeSignal.dispatch( newState );
		}
	}
}
