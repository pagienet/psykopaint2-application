package net.psykosoft.psykopaint2.app.view.navigation
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.ActivePaintingModel;
	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyActivePaintingChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestActivePaintingChangeSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class ViewPaintingSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:ViewPaintingSubNavigationView;

		[Inject]
		public var notifyActivePaintingChangedSignal:NotifyActivePaintingChangedSignal;

		[Inject]
		public var activePaintingModel:ActivePaintingModel;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			view.changeTitle( activePaintingModel.activePaintingName );

			// From app.
			notifyActivePaintingChangedSignal.add( onFocusedPaintingChanged );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From app.
		// -----------------------

		private function onFocusedPaintingChanged( paintingName:String ):void {
			trace( this, "change title: " + paintingName );
			view.changeTitle( paintingName );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			// TODO: not reacting at the time
			switch( buttonLabel ) {

				case ViewPaintingSubNavigationView.BUTTON_LABEL_COMMENT:
//					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) ); // TODO: currently disabled
					break;

				case ViewPaintingSubNavigationView.BUTTON_LABEL_EDIT:
//					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO: currently disabled
					break;

				case ViewPaintingSubNavigationView.BUTTON_LABEL_SHARE:
					requestStateChange( new StateVO( ApplicationStateType.HOME_SCREEN_SHARE ) );
					break;
			}
		}
	}
}
