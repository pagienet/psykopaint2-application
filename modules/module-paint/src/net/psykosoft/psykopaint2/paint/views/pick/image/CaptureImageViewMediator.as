package net.psykosoft.psykopaint2.paint.views.pick.image
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraSnapshotRequest;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;

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
			registerEnablingState( StateType.CAPTURE_IMAGE );
			registerEnablingState( StateType.CONFIRM_CAPTURE_IMAGE );

			notifyCameraSnapshotRequest.add( onCameraSnapshotRequest );
			notifyCameraFlipRequest.add( onCameraFlipRequest );
		}

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			if( newState == StateType.CAPTURE_IMAGE ) {
				view.play();
			}
			else if( newState == StateType.CONFIRM_CAPTURE_IMAGE ){
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
