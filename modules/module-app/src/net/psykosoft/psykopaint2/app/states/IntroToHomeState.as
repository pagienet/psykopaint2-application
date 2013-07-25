package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;

	public class IntroToHomeState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestStateChangeSignal;

		[Inject]
		public var notifyHomeViewZoomCompleteSignal : NotifyHomeViewZoomCompleteSignal;

		[Inject]
		public var homeState : HomeState;

		public function IntroToHomeState()
		{

		}

		override public function activate() : void
		{
			// Trigger initial state...
			notifyHomeViewZoomCompleteSignal.addOnce(onTransitionComplete);
			requestStateChangeSignal.dispatch(StateType.HOME);
		}

		private function onTransitionComplete() : void
		{
			stateMachine.setActiveState(homeState);
		}

		override public function deactivate() : void
		{
		}
	}
}
