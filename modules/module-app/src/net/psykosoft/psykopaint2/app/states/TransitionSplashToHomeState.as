package net.psykosoft.psykopaint2.app.states
{

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.utils.misc.executeNextFrame;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewIntroZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
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
		public var notifyHomeViewZoomCompleteSignal : NotifyHomeViewIntroZoomCompleteSignal;

		[Inject]
		public var requestSetupHomeModuleSignal : RequestSetupHomeModuleSignal;

		[Inject]
		public var notifyHomeModuleSetUpSignal : NotifyHomeModuleSetUpSignal;

		[Inject]
		public var requestHideSplashScreenSignal : RequestHideSplashScreenSignal;

		[Inject]
		public var requestNavigationToggleSignal : RequestNavigationToggleSignal;

		[Inject]
		public var requestHomeIntroSignal:RequestHomeIntroSignal;

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
			requestStateChangeSignal.dispatch(NavigationStateType.HOME);

			// nasty hack, but I really don't care anymore at this point
			// not doing this causes a black frame because the home view will be rendered NEXT frame, it would seem
			executeNextFrame(goHome);
		}

		private function goHome():void
		{
			notifyHomeViewZoomCompleteSignal.addOnce(onTransitionComplete);
			requestHomeIntroSignal.dispatch();
			requestHideSplashScreenSignal.dispatch();
		}

		private function onTransitionComplete() : void
		{
			// TODO: this probably needs to be moved to some activation command
			requestNavigationToggleSignal.dispatch(1, true, false);
			requestStateChangeSignal.dispatch(NavigationStateType.HOME);

			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
