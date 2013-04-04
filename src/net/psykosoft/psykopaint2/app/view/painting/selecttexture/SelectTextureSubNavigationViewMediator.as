package net.psykosoft.psykopaint2.app.view.painting.selecttexture
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class SelectTextureSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SelectTextureSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case SelectTextureSubNavigationView.BUTTON_LABEL_PICK_A_BRUSH:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_BRUSH ) );
					break;
				case SelectTextureSubNavigationView.BUTTON_LABEL_PICK_A_COLOR:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_COLORS ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
					notifyPopUpMessageSignal.dispatch( "Cannot texturize yet, feature not implemented." );
					break;
			}
		}
	}
}
