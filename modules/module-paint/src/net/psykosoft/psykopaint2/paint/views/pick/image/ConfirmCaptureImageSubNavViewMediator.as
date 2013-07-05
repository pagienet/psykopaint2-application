package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraSnapshotRequest;

	public class ConfirmCaptureImageSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ConfirmCaptureImageSubNavView;

		[Inject]
		public var notifyCameraSnapshotRequest:NotifyCameraSnapshotRequest;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case ConfirmCaptureImageSubNavView.LBL_BACK:
				{
					requestStateChange( StateType.CAPTURE_IMAGE );
					break;
				}
				case ConfirmCaptureImageSubNavView.LBL_CONFIRM:
				{
					notifyCameraSnapshotRequest.dispatch();
					break;
				}
			}
		}
	}
}
