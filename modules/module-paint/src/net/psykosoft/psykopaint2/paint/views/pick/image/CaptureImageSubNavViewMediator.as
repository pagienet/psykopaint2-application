package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraFlipRequest;

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

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {
				case CaptureImageSubNavView.LBL_BACK:
				{
					requestStateChange( StateType.PICK_IMAGE );
					break;
				}
				case CaptureImageSubNavView.LBL_CAPTURE:
				{
					requestStateChange( StateType.CONFIRM_CAPTURE_IMAGE );
					break;
				}
				case CaptureImageSubNavView.LBL_FLIP:
				{
					notifyCameraFlipRequest.dispatch();
					break;
				}
			}
		}
	}
}
