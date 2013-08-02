package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;

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

		[Inject]
		public var requestCropSourceImageSignal : RequestCropSourceImageSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		public function HomeState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			// TODO: this probably needs to be moved to some activation command
			requestNavigationToggleSignal.dispatch(1, 0.5);
			requestHomeViewScrollSignal.dispatch(1);

			requestOpenPaintingDataVOSignal.add(onRequestOpenPaintingDataVO);
			requestCropSourceImageSignal.add(onRequestCropState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestOpenPaintingDataVOSignal.remove(onRequestOpenPaintingDataVO);
			requestCropSourceImageSignal.remove(onRequestCropState);
		}

		private function onRequestOpenPaintingDataVO(paintingData : PaintingDataVO) : void
		{
			stateMachine.setActiveState(transitionToPaintState, paintingData);
		}

		private function onRequestCropState(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(cropState, bitmapData);
		}
	}
}
