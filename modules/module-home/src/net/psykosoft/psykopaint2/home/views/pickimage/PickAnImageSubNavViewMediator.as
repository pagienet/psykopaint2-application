package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.login.DeviceCameraUtil;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseSampleImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseUserImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestExitPickAnImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRetrieveCameraImageSignal;

	public class PickAnImageSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:PickAnImageSubNavView;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestBrowseSampleImagesSignal:RequestBrowseSampleImagesSignal;

		[Inject]
		public var requestBrowseUserImagesSignal:RequestBrowseUserImagesSignal;

		[Inject]
		public var requestRetrieveCameraImageSignal:RequestRetrieveCameraImageSignal;

		[Inject]
		public var requestExitPickAnImageSignal:RequestExitPickAnImageSignal;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var requestCropSourceImageSignal:RequestCropSourceImageSignal;

		private var _cameraUtil:DeviceCameraUtil;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Clear easel if entering photo paint.
			if( PaintModeModel.activeMode == PaintMode.PHOTO_MODE ) {
				requestEaselUpdateSignal.dispatch( null, false, false );
			}
		}

		override public function destroy():void {
			super.destroy();
			_cameraUtil.dispose();
			_cameraUtil = null;
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case PickAnImageSubNavView.ID_BACK: {
					requestExitPickAnImageSignal.dispatch();
					requestHomePanningToggleSignal.dispatch( 1 );
					break;
				}

				case PickAnImageSubNavView.ID_USER: {
					requestBrowseUserImagesSignal.dispatch();
					break;
				}

				case PickAnImageSubNavView.ID_SAMPLES: {
					requestBrowseSampleImagesSignal.dispatch();
					break;
				}

				case PickAnImageSubNavView.ID_CAMERA: {
					if( !CoreSettings.RUNNING_ON_iPAD ) {
						requestRetrieveCameraImageSignal.dispatch();
					}
					else {
						takePhoto();
					}
					break;
				}

				/* case PickAnImageSubNavView.ID_FACEBOOK:
				{
					//TODO.
					break;
				}*/
			}
		}

		// -----------------------
		// Photo stuff.
		// -----------------------

		private function takePhoto():void {
			trace( this, "taking photo..." );
			_cameraUtil = new DeviceCameraUtil();
			_cameraUtil.imageRetrievedSignal.add( onPhotoRetrieved );
			_cameraUtil.launch();
		}

		private function onPhotoRetrieved( bmd:BitmapData ):void {
			trace( this, "photo retrieved: " + bmd.width + "x" + bmd.height );
			requestCropSourceImageSignal.dispatch( bmd );
		}
	}
}
