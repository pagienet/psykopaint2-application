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
		public var requestCropSourceImageSignal:RequestCropSourceImageSignal;

		private var _cameraUtil:DeviceCameraUtil;
		private var _rollUtil:CameraRollUtil;

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
					break;
				}

				case PickAnImageSubNavView.ID_USER: {
					if( !CoreSettings.RUNNING_ON_iPAD ) {
						requestBrowseUserImagesSignal.dispatch();
					}
					else {
						loadPhoto();
					}
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
