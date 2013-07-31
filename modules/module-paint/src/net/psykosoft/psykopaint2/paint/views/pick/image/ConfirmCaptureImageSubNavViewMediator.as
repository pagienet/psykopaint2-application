package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraSnapshotRequest;

	public class ConfirmCaptureImageSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:ConfirmCaptureImageSubNavView;

		[Inject]
		public var notifyCameraSnapshotRequest:NotifyCameraSnapshotRequest;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {
				case ConfirmCaptureImageSubNavView.LBL_BACK:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.CAPTURE_IMAGE );
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
