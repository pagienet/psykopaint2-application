package net.psykosoft.psykopaint2.app.view.navigation
{

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyFocusedPaintingChangedSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class PaintingSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:PaintingSubNavigationView;

		[Inject]
		public var notifyFocusedPaintingChangedSignal:NotifyFocusedPaintingChangedSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			notifyFocusedPaintingChangedSignal.add( onFocusedPaintingChanged );

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
			/*switch( buttonLabel ) {
				case PaintingSubNavigationView.BUTTON_LABEL_NEWS1:
//					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) ); // TODO: currently disabled
					break;
				case PaintingSubNavigationView.BUTTON_LABEL_NEWS2:
//					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO: currently disabled
					break;
				case PaintingSubNavigationView.BUTTON_LABEL_NEWS3:
//					requestStateChange( new StateVO( ApplicationStateType.PAINTING ) ); // TODO: currently disabled
					break;
			}*/
		}
	}
}
