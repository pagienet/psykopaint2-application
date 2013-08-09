package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.models.PaintModeType;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class PickAnImageSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:PickAnImageSubNavView;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Clear easel if entering photo paint.
			if( PaintModeModel.activeMode == PaintModeType.PHOTO_MODE ) {
				requestEaselUpdateSignal.dispatch( null, false, false );
			}
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case PickAnImageSubNavView.ID_BACK:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PREVIOUS );
					break;
				}

				case PickAnImageSubNavView.ID_USER:
				{
					requestStateChange__OLD_TO_REMOVE( CoreSettings.RUNNING_ON_iPAD ? NavigationStateType.BOOK_PICK_USER_IMAGE_IOS : NavigationStateType.PICK_USER_IMAGE_DESKTOP );
					break;
				}

				case PickAnImageSubNavView.ID_SAMPLES:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE );
					break;
				}

/*				case PickAnImageSubNavView.ID_FACEBOOK:
				{
					//TODO.
					break;
				}*/

				case PickAnImageSubNavView.ID_CAMERA:
				{
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.CAPTURE_IMAGE );
					break;
				}
			}
		}
	}
}
