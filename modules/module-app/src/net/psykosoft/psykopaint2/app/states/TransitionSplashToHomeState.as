package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySplashScreenRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestHomeIntroSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;

	use namespace ns_state_machine;

	public class TransitionSplashToHomeState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

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
		public var requestHomeIntroSignal:RequestHomeIntroSignal;

		[Inject]
		public var notifySplashScreenRemovedSignal:NotifySplashScreenRemovedSignal;

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
			notifySplashScreenRemovedSignal.addOnce( onSplashScreenRemoved );
			requestHideSplashScreenSignal.dispatch();
		}

		private function onSplashScreenRemoved():void {
			notifyHomeViewZoomCompleteSignal.addOnce(onTransitionComplete);
			requestHomeIntroSignal.dispatch();
			requestStateChangeSignal.dispatch(NavigationStateType.HOME);
		}

		private function onTransitionComplete() : void
		{
			// TODO: this probably needs to be moved to some activation command
			requestNavigationToggleSignal.dispatch(1);
			requestHomeViewScrollSignal.dispatch(1);

			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
