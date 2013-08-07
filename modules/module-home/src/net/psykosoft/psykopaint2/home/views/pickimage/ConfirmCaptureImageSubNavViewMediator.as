package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraSnapshotRequest;

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

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case ConfirmCaptureImageSubNavView.ID_BACK:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.CAPTURE_IMAGE );
					break;
				}
				case ConfirmCaptureImageSubNavView.ID_CONFIRM:
				{
					notifyCameraSnapshotRequest.dispatch();
					break;
				}
			}
		}
	}
}
