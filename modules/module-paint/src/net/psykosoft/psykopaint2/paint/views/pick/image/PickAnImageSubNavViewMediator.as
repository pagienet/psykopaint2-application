package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PickAnImageSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickAnImageSubNavView;

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

				case PickAnImageSubNavView.LBL_BACK:
				{
					requestStateChange( StateType.HOME_PICK_SURFACE );
					break;
				}

				case PickAnImageSubNavView.LBL_USER:
				{
					requestStateChange( CoreSettings.RUNNING_ON_iPAD ? StateType.BOOK_PICK_USER_IMAGE_IOS : StateType.PICK_USER_IMAGE_DESKTOP );
					break;
				}

				case PickAnImageSubNavView.LBL_SAMPLES:
				{
					requestStateChange( StateType.BOOK_PICK_SAMPLE_IMAGE );
					break;
				}

/*				case PickAnImageSubNavView.LBL_FACEBOOK:
				{
					//TODO.
					break;
				}*/

				case PickAnImageSubNavView.LBL_CAMERA:
				{
					requestStateChange( StateType.CAPTURE_IMAGE );
					break;
				}
			}
		}
	}
}
