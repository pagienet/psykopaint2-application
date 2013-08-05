package net.psykosoft.psykopaint2.app.states
{
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;

	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;

	use namespace ns_state_machine;

	public class TransitionHomeToPaintState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var requestCreateCanvasBackgroundSignal : RequestCreateCanvasBackgroundSignal;

		[Inject]
		public var requestSetupPaintModuleSignal : RequestSetupPaintModuleSignal;

		[Inject]
		public var notifyPaintModuleSetUp : NotifyPaintModuleSetUpSignal;

		[Inject]
		public var requestZoomCanvasToDefaultViewSignal:RequestZoomCanvasToDefaultViewSignal;

		[Inject]
		public var notifyCanvasBackgroundSetSignal : NotifyFrozenBackgroundCreatedSignal;

		[Inject]
		public var paintState : PaintState;

		[Inject]
		public var requestDestroyHomeModuleSignal : RequestDestroyHomeModuleSignal;

		public function TransitionHomeToPaintState()
		{
		}

		/**
		 * @param data A PaintingDataVO object containing the data to import to the canvas
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(PaintingDataVO(data));
		}

		private function onPaintingModuleSetUp() : void
		{
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

			requestDestroyHomeModuleSignal.dispatch();
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
