package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.models.PaintModeType;
	import net.psykosoft.psykopaint2.core.signals.RequestBrowseSampleImagesSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestBrowseUserImagesSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class PickAnImageSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:PickAnImageSubNavView;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestBrowseSampleImagesSignal:RequestBrowseSampleImagesSignal;

		[Inject]
		public var requestBrowseUserImagesSignal:RequestBrowseUserImagesSignal;

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
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.HOME_ON_EASEL );
					break;
				}

				case PickAnImageSubNavView.ID_USER:
				{
					requestBrowseUserImagesSignal.dispatch();
					if( CoreSettings.RUNNING_ON_iPAD ) {
						requestStateChange__OLD_TO_REMOVE( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS );
					}
					else {
						requestStateChange__OLD_TO_REMOVE( NavigationStateType.PICK_USER_IMAGE_DESKTOP );
					}
					break;
				}

				case PickAnImageSubNavView.ID_SAMPLES:
				{
					requestBrowseSampleImagesSignal.dispatch();
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
