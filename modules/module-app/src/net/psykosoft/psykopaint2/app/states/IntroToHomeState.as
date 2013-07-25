package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;

	use namespace ns_state_machine;

	public class IntroToHomeState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestStateChangeSignal_OLD_TO_REMOVE;

		[Inject]
		public var notifyHomeViewZoomCompleteSignal : NotifyHomeViewZoomCompleteSignal;

		[Inject]
		public var homeState : HomeState;

		public function IntroToHomeState()
		{

		}

		override ns_state_machine function activate() : void
		{
			// Trigger initial state...
			notifyHomeViewZoomCompleteSignal.addOnce(onTransitionComplete);
			requestStateChangeSignal.dispatch(StateType.HOME);
		}

		private function onTransitionComplete() : void
		{
			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
		}
	}
}
