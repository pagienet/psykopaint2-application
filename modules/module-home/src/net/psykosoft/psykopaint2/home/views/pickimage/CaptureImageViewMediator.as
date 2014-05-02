package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleLoadingMessageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraSnapshotRequest;

	public class CaptureImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CaptureImageView;

		[Inject]
		public var notifyCameraSnapshotRequest:NotifyCameraSnapshotRequest;

		[Inject]
		public var notifyCameraFlipRequest:NotifyCameraFlipRequest;

		[Inject]
		public var requestCropSourceImageSignal:RequestCropSourceImageSignal;
		
		[Inject]
		public var notifyToggleLoadingMessageSignal:NotifyToggleLoadingMessageSignal;
		

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.CAPTURE_IMAGE );

			notifyCameraSnapshotRequest.add( onCameraSnapshotRequest );
			notifyCameraFlipRequest.add( onCameraFlipRequest );
		}

		override public function destroy():void {
			view.disable();
			notifyCameraSnapshotRequest.remove( onCameraSnapshotRequest );
			notifyCameraFlipRequest.remove( onCameraFlipRequest );
			view.dispose();
			super.destroy();
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			if( newState == NavigationStateType.CAPTURE_IMAGE ) {
				view.play();
			}
		}

		private function onCameraSnapshotRequest():void {
			view.pause();
			notifyToggleLoadingMessageSignal.dispatch(true);
			var bmd:BitmapData = view.takeSnapshot();
			requestCropSourceImageSignal.dispatch( bmd, CameraRollImageOrientation.ROTATION_0 );
		}

		private function onCameraFlipRequest():void {
			view.flipCamera();
		}
	}
}
