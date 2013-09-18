package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestBrowseSampleImagesSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestBrowseUserImagesSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestExitPickAnImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestRetrieveCameraImageSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;

	use namespace ns_state_machine;

	public class HomeState extends State
	{
		[Inject]
		public var requestStateChange : RequestNavigationStateChangeSignal;

		[Inject]
		public var transitionToPaintState : TransitionHomeToPaintState;

		[Inject]
		public var transitionToCropState : TransitionHomeToCropState;

		[Inject]
		public var transitionToBookState : TransitionHomeToBookState;

		[Inject]
		public var requestCropSourceImageSignal : RequestCropSourceImageSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		[Inject]
		public var transitionCropToHomeState : TransitionCropToHomeState;

		[Inject]
		public var transitionPaintToHomeState : TransitionPaintToHomeState;

		[Inject]
		public var transitionBookToHomeState : TransitionBookToHomeState;

		[Inject]
		public var requestBrowseSampleImagesSignal : RequestBrowseSampleImagesSignal;

		[Inject]
		public var requestBrowseUserImagesSignal : RequestBrowseUserImagesSignal;

		[Inject]
		public var requestRetrieveCameraImageSignal:RequestRetrieveCameraImageSignal;

		[Inject]
		public var requestExitPickAnImageSignal:RequestExitPickAnImageSignal;

		public function HomeState()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			// manual injection because robotlegs crashes injecting circular dependencies
			transitionCropToHomeState.homeState = this;
			transitionPaintToHomeState.homeState = this;
			transitionBookToHomeState.homeState = this;
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			requestOpenPaintingDataVOSignal.add(onRequestOpenPaintingDataVO);
			requestCropSourceImageSignal.add(onRequestCropState);
			requestBrowseSampleImagesSignal.add(onBrowseSampleImagesSignal);
			requestBrowseUserImagesSignal.add(onBrowseUserImagesSignal);
			requestRetrieveCameraImageSignal.add(onRequestRetrieveCameraImageSignal);
			requestExitPickAnImageSignal.add(onRequestExitPickAnImageSignal);
		}

		override ns_state_machine function deactivate() : void
		{
			requestOpenPaintingDataVOSignal.remove(onRequestOpenPaintingDataVO);
			requestCropSourceImageSignal.remove(onRequestCropState);
			requestBrowseSampleImagesSignal.remove(onBrowseSampleImagesSignal);
			requestBrowseUserImagesSignal.remove(onBrowseUserImagesSignal);
			requestRetrieveCameraImageSignal.remove(onRequestRetrieveCameraImageSignal);
			requestExitPickAnImageSignal.remove(onRequestExitPickAnImageSignal);
		}

		private function onRequestOpenPaintingDataVO(paintingData : PaintingDataVO) : void
		{
			stateMachine.setActiveState(transitionToPaintState, paintingData);
		}

		private function onRequestCropState(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToCropState, bitmapData);
		}

		private function onBrowseUserImagesSignal() : void
		{
			if (CoreSettings.RUNNING_ON_iPAD)
				stateMachine.setActiveState(transitionToBookState, BookImageSource.USER_IMAGES);
			else
				requestStateChange.dispatch(NavigationStateType.PICK_USER_IMAGE_DESKTOP);
		}

		private function onBrowseSampleImagesSignal() : void
		{
			stateMachine.setActiveState(transitionToBookState, BookImageSource.SAMPLE_IMAGES);
		}

		private function onRequestExitPickAnImageSignal():void {
			requestStateChange.dispatch( NavigationStateType.HOME_ON_EASEL );
		}

		private function onRequestRetrieveCameraImageSignal():void {
			requestStateChange.dispatch( NavigationStateType.CAPTURE_IMAGE );
		}
	}
}
