package net.psykosoft.psykopaint2.app.view.painting.selectimage
{

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestReadyToPaintThumbnailsSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectImageSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectImageSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var requestReadyToPaintThumbnailsSignal:RequestReadyToPaintThumbnailsSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case SelectImageSubNavigationView.BUTTON_LABEL_NEW_PAINTING:
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.PAINTING ) );
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_FACEBOOK:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_CAMERA:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO
//					notifyPopUpDisplaySignal.dispatch( PopUpType.CAPTURE_IMAGE );
//					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_CAPTURE_IMAGE ) );
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_READY_TO_PAINT:
					requestReadyToPaintThumbnailsSignal.dispatch();
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_YOUR_PHOTOS:
					if( Settings.RUNNING_ON_iPAD ) {
						notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO
					}
					else {
						notifyPopUpDisplaySignal.dispatch( PopUpType.NO_PLATFORM );
					}
					break;
			}
		}
	}
}
