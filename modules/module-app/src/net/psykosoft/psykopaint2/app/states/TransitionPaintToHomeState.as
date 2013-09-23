package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToEaselViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestDestroyPaintModuleSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToEaselViewSignal;

	public class TransitionPaintToHomeState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestSetupHomeModuleSignal : RequestSetupHomeModuleSignal;

		[Inject]
		public var notifyHomeModuleSetUpSignal : NotifyHomeModuleSetUpSignal;

		[Inject]
		public var requestDestroyPaintModuleSignal : RequestDestroyPaintModuleSignal;

		[Inject]
		public var requestZoomCanvasToEaselViewSignal : RequestZoomCanvasToEaselViewSignal;

		[Inject]
		public var notifyPaintModuleDestroyedSignal:NotifyPaintModuleDestroyedSignal;

		[Inject]
		public var notifyCanvasZoomedToEaselViewSignal:NotifyCanvasZoomedToEaselViewSignal;

		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		// needs to be set from HomeState -_-
		public var homeState : HomeState;

		public function TransitionPaintToHomeState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			notifyHomeModuleSetUpSignal.addOnce(onHomeModuleSetUp);
			requestSetupHomeModuleSignal.dispatch();
		}

		private function onHomeModuleSetUp() : void
		{
			zoomOut();
		}

		private function zoomOut():void {
			notifyCanvasZoomedToEaselViewSignal.addOnce( onZoomOutComplete );
			requestZoomCanvasToEaselViewSignal.dispatch();
		}

		private function onZoomOutComplete() : void
		{
			// remove all these transition and prepare crazies:
			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_HOME_MODE);
			requestStateChangeSignal.dispatch(NavigationStateType.PREPARE_FOR_HOME_MODE);
			stateMachine.setActiveState(homeState);
			hideSavingPopUp();
		}

		private function hideSavingPopUp():void {
			notifyPopUpRemovedSignal.addOnce( zoomOut );
			requestHidePopUpSignal.dispatch();
		}

		override ns_state_machine function deactivate() : void
		{
			notifyPaintModuleDestroyedSignal.addOnce( onPaintModuleDestroyed );
			requestDestroyPaintModuleSignal.dispatch();
		}

		private function onPaintModuleDestroyed():void {
			requestStateChangeSignal.dispatch(NavigationStateType.HOME_ON_EASEL);
		}
	}
}
