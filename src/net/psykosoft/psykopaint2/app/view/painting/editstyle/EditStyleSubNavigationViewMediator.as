package net.psykosoft.psykopaint2.app.view.painting.editstyle
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class EditStyleSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:EditStyleSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		override public function initialize():void {

			super.initialize();
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case EditStyleSubNavigationView.BUTTON_LABEL_SELECT_STYLE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_STYLE ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
					notifyPopUpMessageSignal.dispatch( "Cannot use properties yet, feature not implemented." );
					break;
			}
		}
	}
}
