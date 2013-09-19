package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraSnapshotRequest;

	public class CaptureImageSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CaptureImageSubNavView;

		[Inject]
		public var notifyCameraFlipRequest:NotifyCameraFlipRequest;

		[Inject]
		public var notifyCameraSnapshotRequest:NotifyCameraSnapshotRequest;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case CaptureImageSubNavView.ID_BACK:
				{
					requestNavigationStateChange( NavigationStateType.PICK_IMAGE );
					break;
				}
				case CaptureImageSubNavView.ID_CAPTURE:
				{
					notifyCameraSnapshotRequest.dispatch();
					break;
				}
				case CaptureImageSubNavView.ID_FLIP:
				{
					notifyCameraFlipRequest.dispatch();
					break;
				}
			}
		}
	}
}
