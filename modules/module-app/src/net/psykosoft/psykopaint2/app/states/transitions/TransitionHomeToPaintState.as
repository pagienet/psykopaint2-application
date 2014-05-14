package net.psykosoft.psykopaint2.app.states.transitions
{
	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.app.states.PaintState;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleSetUpSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetupPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;

	use namespace ns_state_machine;

	public class TransitionHomeToPaintState extends AbstractTransitionState
	{
		[Inject]
		public var requestNavigationStateChangeSignal : RequestNavigationStateChangeSignal;

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

		[Inject]
		public var notifyCanvasZoomedToDefaultViewSignal:NotifyCanvasZoomedToDefaultViewSignal;

		public function TransitionHomeToPaintState()
		{
		}

		/**
		 * @param data A PaintingDataVO object containing the data to import to the canvas
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			use namespace ns_state_machine;
			super.activate(data);

			notifyPaintModuleSetUp.addOnce(onPaintingModuleSetUp);
			requestSetupPaintModuleSignal.dispatch(PaintingDataVO(data));
			

		}

		private function onPaintingModuleSetUp() : void
		{
			notifyCanvasBackgroundSetSignal.addOnce(onCanvasBackgroundSet);
			requestCreateCanvasBackgroundSignal.dispatch();
		}

		private function onCanvasBackgroundSet(background : RefCountedRectTexture) : void
		{
			notifyCanvasZoomedToDefaultViewSignal.addOnce( onZoomComplete );
			requestZoomCanvasToDefaultViewSignal.dispatch();

			requestNavigationStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_PAINT_MODE);
		}

		private function onZoomComplete() : void
		{
			requestDestroyHomeModuleSignal.dispatch();
			stateMachine.setActiveState(paintState);
		}

		override ns_state_machine function deactivate() : void
		{
			use namespace ns_state_machine;
			super.deactivate();

		}
	}
}
