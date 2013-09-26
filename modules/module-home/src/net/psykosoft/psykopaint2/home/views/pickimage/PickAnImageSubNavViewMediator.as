package net.psykosoft.psykopaint2.home.views.pickimage
{

	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseSampleImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestBrowseUserImagesSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestExitPickAnImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestRetrieveCameraImageSignal;

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

		[Inject]
		public var requestRetrieveCameraImageSignal:RequestRetrieveCameraImageSignal;

		[Inject]
		public var requestExitPickAnImageSignal:RequestExitPickAnImageSignal;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Clear easel if entering photo paint.
			if( PaintModeModel.activeMode == PaintMode.PHOTO_MODE ) {
				requestEaselUpdateSignal.dispatch( null, false, false );
			}
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case PickAnImageSubNavView.ID_BACK: {
					requestExitPickAnImageSignal.dispatch();
					requestHomePanningToggleSignal.dispatch( 1 );
					break;
				}

				case PickAnImageSubNavView.ID_USER: {
					requestBrowseUserImagesSignal.dispatch();
					break;
				}

				case PickAnImageSubNavView.ID_SAMPLES: {
					requestBrowseSampleImagesSignal.dispatch();
					break;
				}

				case PickAnImageSubNavView.ID_CAMERA: {
					requestRetrieveCameraImageSignal.dispatch();
					break;
				}

				/* case PickAnImageSubNavView.ID_FACEBOOK:
				{
					//TODO.
					break;
				}*/
			}
		}
	}
}
