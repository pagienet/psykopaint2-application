package net.psykosoft.psykopaint2.app.states
{
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.signals.NotifyCanvasBackgroundSetSignal;

	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleCommand;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;

	use namespace ns_state_machine;

	public class TransitionHomeToPaintState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var requestCreateCanvasBackgroundSignal : RequestCreateCanvasBackgroundSignal;

		[Inject]
		public var requestSetupPaintModuleSignal : RequestSetupPaintModuleCommand;

		[Inject]
		public var requestDestroyHomeModuleSignal : RequestDestroyHomeModuleSignal;

		[Inject]
		public var requestZoomCanvasToDefaultViewSignal:RequestZoomCanvasToDefaultViewSignal;

		[Inject]
		public var notifyCanvasBackgroundSetSignal : NotifyCanvasBackgroundSetSignal;

		[Inject]
		public var paintState : PaintState;

		public function TransitionHomeToPaintState()
		{
		}

		override ns_state_machine function activate() : void
		{
			requestSetupPaintModuleSignal.dispatch();
			notifyCanvasBackgroundSetSignal.addOnce(onCanvasBackgroundSet);
			requestCreateCanvasBackgroundSignal.dispatch();

			// todo: remove state change signals, replace by proper signals
			// this is only to switch views
			requestStateChangeSignal.dispatch(NavigationStateType.PREPARE_FOR_PAINT_MODE);
		}

		private function onCanvasBackgroundSet() : void
		{
			requestZoomCanvasToDefaultViewSignal.dispatch(onZoomOutComplete);
			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
		}

		private function onZoomOutComplete() : void
		{
			stateMachine.setActiveState(paintState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyHomeModuleSignal.dispatch();
		}
	}
}
