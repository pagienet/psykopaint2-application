package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;
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

		public var homeState : State;

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
			requestZoomCanvasToEaselViewSignal.dispatch(onZoomOutComplete);
		}

		private function onZoomOutComplete() : void
		{
			// remove all these transition and prepare crazies:
			requestStateChangeSignal.dispatch(NavigationStateType.TRANSITION_TO_HOME_MODE);
			requestStateChangeSignal.dispatch(NavigationStateType.PREPARE_FOR_HOME_MODE);
			requestStateChangeSignal.dispatch(NavigationStateType.HOME_ON_EASEL);
			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyPaintModuleSignal.dispatch();
		}
	}
}
