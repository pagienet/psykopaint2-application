package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyCameraFlipRequest;

	public class CaptureImageSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CaptureImageSubNavView;

		[Inject]
		public var notifyCameraFlipRequest:NotifyCameraFlipRequest;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case CaptureImageSubNavView.ID_BACK:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PICK_IMAGE );
					break;
				}
				case CaptureImageSubNavView.ID_CAPTURE:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.CONFIRM_CAPTURE_IMAGE );
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
