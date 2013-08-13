package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestClosePaintViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestPaintingSaveSignal;

	use namespace ns_state_machine;

	public class PaintState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var transitionToHomeState : TransitionPaintToHomeState;

		[Inject]
		public var requestClosePaintView : RequestClosePaintViewSignal;

		[Inject]
		public var requestPaintingSaveSignal : RequestPaintingSaveSignal;

		[Inject]
		public var notifyPaintingSavedSignal : NotifyPaintingSavedSignal;

		[Inject]
		public var paintingModel : PaintingModel;


		public function PaintState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			requestClosePaintView.add(onClosePaintView);
			requestStateChangeSignal.dispatch(NavigationStateType.PAINT_SELECT_BRUSH);
		}

		override ns_state_machine function deactivate() : void
		{
			requestClosePaintView.remove(onClosePaintView);
		}

		private function onClosePaintView() : void
		{
			notifyPaintingSavedSignal.addOnce(onPaintingSaved);
			requestPaintingSaveSignal.dispatch(paintingModel.activePaintingId, true);
		}


		private function onPaintingSaved(success : Boolean) : void
		{
			stateMachine.setActiveState(transitionToHomeState);
		}
	}
}
