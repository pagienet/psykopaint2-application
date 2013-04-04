package net.psykosoft.psykopaint2.app.view.selectimage
{

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.types.ImageSourceType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestImageSourceSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpType;

	public class SelectImageSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SelectImageSubNavigationView;

		[Inject]
		public var requestImageSourceSignal:RequestImageSourceSignal;

//		[Inject]
//		public var requestUserPhotosThumbnailsSignal:RequestUserPhotosThumbnailsSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

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

				case SelectImageSubNavigationView.BUTTON_LABEL_NEW_PAINTING:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING ) );
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_FACEBOOK:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO...
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_CAMERA:
					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO...
//					notifyPopUpDisplaySignal.dispatch( PopUpType.CAPTURE_IMAGE );
//					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_CAPTURE_IMAGE ) );
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_READY_TO_PAINT:
					requestImageSourceSignal.dispatch( ImageSourceType.READY_TO_PAINT );
					break;

				case SelectImageSubNavigationView.BUTTON_LABEL_YOUR_PHOTOS:
					if( Settings.RUNNING_ON_iPAD ) {
						if( Settings.USER_NATIVE_USER_PHOTOS_BROWSER ) requestImageSourceSignal.dispatch( ImageSourceType.IOS_USER_PHOTOS_NATIVE );
						else requestImageSourceSignal.dispatch( ImageSourceType.IOS_USER_PHOTOS_ANE );
					}
					else requestImageSourceSignal.dispatch( ImageSourceType.DESKTOP );
					break;
			}
		}
	}
}
