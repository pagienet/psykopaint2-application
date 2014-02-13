package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.GalleryType;
	import net.psykosoft.psykopaint2.core.models.ImageCollectionSource;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
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
		public var requestCropSourceImageSignal : RequestCropSourceImageSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		[Inject]
		public var transitionCropToHomeState : TransitionCropToHomeState;

		[Inject]
		public var transitionPaintToHomeState : TransitionPaintToHomeState;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		[Inject]
		public var navigationCanHideWithGesturesSignal:NavigationCanHideWithGesturesSignal;

		[Inject]
		public var notifyNavigationStateChangeSignal:NotifyNavigationStateChangeSignal;

		[Inject]
		public var bookLayer : BookStateLayer;



		public function HomeState()
		{
		}

		[PostConstruct]
		public function init() : void
		{
			// manual injection because robotlegs crashes injecting circular dependencies
			transitionCropToHomeState.homeState = this;
			transitionPaintToHomeState.homeState = this;
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			ConsoleView.instance.log( this, "activating..." );
			ConsoleView.instance.logMemory();
			requestOpenPaintingDataVOSignal.add(onRequestOpenPaintingDataVO);
			requestCropSourceImageSignal.add(onRequestCropState);

			notifyNavigationStateChangeSignal.add(onNavigationStateChange);
			navigationCanHideWithGesturesSignal.dispatch( false );
			requestNavigationToggleSignal.dispatch( 1 );
		}

		override ns_state_machine function deactivate() : void
		{
			ConsoleView.instance.log( this, "de-activating..." );
			ConsoleView.instance.logMemory();
			notifyNavigationStateChangeSignal.remove(onNavigationStateChange);
			requestOpenPaintingDataVOSignal.remove(onRequestOpenPaintingDataVO);
			requestCropSourceImageSignal.remove(onRequestCropState);
		}

		private function onRequestOpenPaintingDataVO(paintingData : PaintingDataVO) : void
		{
			stateMachine.setActiveState(transitionToPaintState, paintingData);
		}

		private function onRequestCropState(bitmapData : BitmapData, orientation:int ) : void
		{
			//TODO: handle orientation
			stateMachine.setActiveState(transitionToCropState, {map:bitmapData, orientation:orientation });
		}

		private function onNavigationStateChange(state : String) : void
		{
			switch (state) {
				case NavigationStateType.PICK_USER_IMAGE_IOS:
					bookLayer.show(ImageCollectionSource.CAMERAROLL_IMAGES);
					break;
				case NavigationStateType.PICK_SAMPLE_IMAGE:
					bookLayer.show(ImageCollectionSource.SAMPLE_IMAGES);
					break;
				case NavigationStateType.GALLERY_BROWSE_FOLLOWING:
					bookLayer.show(ImageCollectionSource.GALLERY_IMAGES, GalleryType.FOLLOWING);
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_LOVED:
					bookLayer.show(ImageCollectionSource.GALLERY_IMAGES, GalleryType.MOST_LOVED);
					break;
				case NavigationStateType.GALLERY_BROWSE_MOST_RECENT:
					bookLayer.show(ImageCollectionSource.GALLERY_IMAGES, GalleryType.MOST_RECENT);
					break;
				case NavigationStateType.GALLERY_BROWSE_YOURS:
					bookLayer.show(ImageCollectionSource.GALLERY_IMAGES, GalleryType.YOURS);
					break;
				case NavigationStateType.GALLERY_BROWSE_USER:
					bookLayer.show(ImageCollectionSource.GALLERY_IMAGES, GalleryType.USER);
					break;
				case NavigationStateType.GALLERY_PAINTING:
					// keep the book where it was
					break;
				default:
					bookLayer.hide();
			}
		}
	}
}
