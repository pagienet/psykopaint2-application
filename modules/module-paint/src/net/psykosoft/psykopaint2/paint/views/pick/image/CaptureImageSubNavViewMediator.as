package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCameraFlipRequest;

	public class CaptureImageSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CaptureImageSubNavView;

		[Inject]
		public var notifyCameraFlipRequest:NotifyCameraFlipRequest;

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
				case CaptureImageSubNavView.LBL_BACK:
				{
					requestStateChange__OLD_TO_REMOVE( StateType.PICK_IMAGE );
					break;
				}
				case CaptureImageSubNavView.LBL_CAPTURE:
				{
					requestStateChange__OLD_TO_REMOVE( StateType.CONFIRM_CAPTURE_IMAGE );
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
