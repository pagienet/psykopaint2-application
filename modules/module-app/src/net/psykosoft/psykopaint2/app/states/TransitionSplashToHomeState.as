package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;

	use namespace ns_state_machine;

	public class TransitionSplashToHomeState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var notifyHomeViewZoomCompleteSignal : NotifyHomeViewZoomCompleteSignal;

		[Inject]
		public var requestSetupHomeModuleSignal : RequestSetupHomeModuleSignal;

		[Inject]
		public var notifyHomeModuleSetUpSignal : NotifyHomeModuleSetUpSignal;

		[Inject]
		public var requestHideSplashScreenSignal : RequestHideSplashScreenSignal;

		[Inject]
		public var requestNavigationToggleSignal : RequestNavigationToggleSignal;

		[Inject]
		public var requestHomeViewScrollSignal : RequestHomeViewScrollSignal;

		[Inject]
		public var homeState : HomeState;

		public function TransitionSplashToHomeState()
		{

		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			notifyHomeModuleSetUpSignal.addOnce(onHomeModuleSetUp);
			requestSetupHomeModuleSignal.dispatch();
		}

		private function onHomeModuleSetUp() : void
		{
			// Trigger initial state...
			notifyHomeViewZoomCompleteSignal.addOnce(onTransitionComplete);

			requestHideSplashScreenSignal.dispatch();

			// todo: remove this signal and replace it with a "transitionToDefaultView" signal
			requestStateChangeSignal.dispatch(NavigationStateType.HOME);
		}

		private function onTransitionComplete() : void
		{
			// TODO: this probably needs to be moved to some activation command
			requestNavigationToggleSignal.dispatch(1, 0.5);
			requestHomeViewScrollSignal.dispatch(1);

			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
