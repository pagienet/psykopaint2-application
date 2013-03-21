package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.IModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.SmearModule;

	public class UpdateAppStateFromActivatedDrawingCoreModuleCommand
	{
		[Inject]
		public var moduleJustActivated:IModule;

		////////////////////////////////////////////////////////////////////////////////

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var cropModule:CropModule;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var smearModule:SmearModule;

		////////////////////////////////////////////////////////////////////////////////

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		////////////////////////////////////////////////////////////////////////////////

		public function execute():void {

			var newState:StateVO;

			switch( moduleJustActivated ) {

				case paintModule:
					newState = new StateVO( StateType.PAINTING_SELECT_BRUSH );
					break;

				case cropModule:
					newState = new StateVO( StateType.PAINTING_CROP_IMAGE );
					break;

				case colorStyleModule:
					newState = new StateVO( StateType.PAINTING_SELECT_COLORS );
					break;

				case smearModule:
					throw new Error( "Don't know what to do with this module..." );
					break;

				// TODO: there are still application states not associated here.

			}

			Cc.log( this, "drawing core module activated: " + moduleJustActivated + ", triggering app state: " + newState.name );

			requestStateChangeSignal.dispatch( newState );

		}
	}
}
