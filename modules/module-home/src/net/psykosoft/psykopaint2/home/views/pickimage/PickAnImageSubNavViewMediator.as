package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.login.CameraRollUtil;
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
		private var _rollUtil:CameraRollUtil;

		/*

        Notes on the Context3D loss and toolbar reappearing:

        Atm we are using
        CoreSettings.USE_NATIVE_CAMERA_ROLL_TO_RETRIEVE_USER_IMAGES = false
        CoreSettings.USE_NATIVE_CAMERA_TO_RETRIEVE_USER_PICTURE = false

        These 2 settings tell the app to use our custom camera and our custom browser ( the book ) to retrieve images from the user's library.
        We want to use the native iOS camera app and the native camera roll pop up, which are activated by settings those 2 vars to true,
        but we can't atm because there is a bug in AIR 3.9 in which the 3D context is loss while triggering any of those 2 iOS elements.
        This didn't happen in AIR 3.8 and has been reported to Adobe.

        https://bugbase.adobe.com/index.cfm?event=bug&id=3633422

        So, we are waiting for a fix. We can easily check if it has been fixed by updating our AIR 3.9 SDK and settings those 2 vars to true.

        Note that there is a secondary bug associated to this in which not only the context is lost, but the iOS top toolbar reappears. Our app
        doesnt use it and we tell it so in the app config xml
        <fullScreen>true</fullScreen>
        <key>UIViewControllerBasedStatusBarAppearance</key>
		<false/>
		<key>UIStatusBarStyle</key>
		<string>UIStatusBarStyleLightContent</string>

		However, opening the any of the iOS elements reshows the bar. There is a workaround for this by resetting the the stage's fullscreen nature from
		AS3, but we'd rather wait for the AIR 3.9 fix. If you do want to see more on that, there is more info on the workaround in the adobe link above.

		 */

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

		}

		override public function destroy():void {
			super.destroy();

			if( _cameraUtil ) {
				_cameraUtil.dispose();
				_cameraUtil = null;
			}

			if( _rollUtil ) {
				_rollUtil.dispose();
				_rollUtil = null;
			}
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case PickAnImageSubNavView.ID_BACK: {
					requestExitPickAnImageSignal.dispatch();
					requestHomePanningToggleSignal.dispatch( 1 );
					break;
				}

				case PickAnImageSubNavView.ID_USER: {
					if( !CoreSettings.RUNNING_ON_iPAD || !CoreSettings.USE_NATIVE_CAMERA_ROLL_TO_RETRIEVE_USER_IMAGES ) requestBrowseUserImagesSignal.dispatch();
					else loadPhoto();
					break;
				}

				case PickAnImageSubNavView.ID_SAMPLES: {
					requestBrowseSampleImagesSignal.dispatch();
					break;
				}

				case PickAnImageSubNavView.ID_CAMERA: {
					if( !CoreSettings.RUNNING_ON_iPAD || !CoreSettings.USE_NATIVE_CAMERA_TO_RETRIEVE_USER_PICTURE ) requestRetrieveCameraImageSignal.dispatch();
					else takePhoto();
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

		private function loadPhoto():void {
			_rollUtil = new CameraRollUtil();
			_rollUtil.imageRetrievedSignal.add( onPhotoRetrieved );
			var w:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1024 : 512;
			var h:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 512 : 256;
			_rollUtil.launch( new Rectangle( view.mouseX, view.mouseY, 100, 100 ), w, h );
		}

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
