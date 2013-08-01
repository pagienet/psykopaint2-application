package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.signals.RequestCropStateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintStateSignal;

	use namespace ns_state_machine;

	public class HomeState extends State
	{
		[Inject]
		public var requestNavigationToggleSignal : RequestNavigationToggleSignal;

		[Inject]
		public var requestHomeViewScrollSignal : RequestHomeViewScrollSignal;

		[Inject]
		public var transitionToPaintState : TransitionHomeToPaintState;

		[Inject]
		public var cropState : CropState;

		// TODO: Replace this with signals exclusive home module
		[Inject]
		public var requestPaintStateSignal : RequestPaintStateSignal;

		[Inject]
		public var requestCropStateSignal : RequestCropStateSignal;

		public function HomeState()
		{
		}

		override ns_state_machine function activate() : void
		{
			// TODO: this probably needs to be moved to some activation command
			requestNavigationToggleSignal.dispatch(1, 0.5);
			requestHomeViewScrollSignal.dispatch(1);

			requestPaintStateSignal.add(onRequestPaintState);
			requestCropStateSignal.add(onRequestCropState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestPaintStateSignal.remove(onRequestPaintState);
			requestCropStateSignal.remove(onRequestCropState);
		}

		private function onRequestPaintState() : void
		{
			stateMachine.setActiveState(transitionToPaintState);
		}

		private function onRequestCropState(bitmapData : BitmapData) : void
		{
			cropState.setSourceBitmapData(bitmapData);
			stateMachine.setActiveState(cropState);
		}
	}
}
