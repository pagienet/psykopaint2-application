package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
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

			navigationCanHideWithGesturesSignal.dispatch( false );
			requestNavigationToggleSignal.dispatch( 1 );
		}

		override ns_state_machine function deactivate() : void
		{
			ConsoleView.instance.log( this, "de-activating..." );
			ConsoleView.instance.logMemory();
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
	}
}
