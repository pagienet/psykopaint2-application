package net.psykosoft.psykopaint2.paint.views.pick.image
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestSourceImageSetSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraSnapshotRequest;

	public class CaptureImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CaptureImageView;

		[Inject]
		public var notifyCameraSnapshotRequest:NotifyCameraSnapshotRequest;

		[Inject]
		public var notifyCameraFlipRequest:NotifyCameraFlipRequest;

		[Inject]
		public var requestSourceImageSetSignal:RequestSourceImageSetSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.CAPTURE_IMAGE );
			registerEnablingState( NavigationStateType.CONFIRM_CAPTURE_IMAGE );

			notifyCameraSnapshotRequest.add( onCameraSnapshotRequest );
			notifyCameraFlipRequest.add( onCameraFlipRequest );
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			if( newState == NavigationStateType.CAPTURE_IMAGE ) {
				view.play();
			}
			else if( newState == NavigationStateType.CONFIRM_CAPTURE_IMAGE ){
				view.pause();
			}
		}

		private function onCameraSnapshotRequest():void {
			var bmd:BitmapData = view.takeSnapshot();
			requestSourceImageSetSignal.dispatch( bmd );
		}

		private function onCameraFlipRequest():void {
			view.flipCamera();
		}
	}
}
