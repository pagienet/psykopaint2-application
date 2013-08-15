package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;

	public class TransitionBookToHomeState extends State
	{
		// injected from HomeState due to circular dependency
		public var homeState : HomeState;

		[Inject]
		public var requestDestroyBookModuleSignal : RequestDestroyBookModuleSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestSetupHomeModuleSignal : RequestSetupHomeModuleSignal;

		[Inject]
		public var notifyHomeModuleSetUpSignal : NotifyHomeModuleSetUpSignal;

		public function TransitionBookToHomeState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			notifyHomeModuleSetUpSignal.addOnce(onHomeModuleSetUp);
			requestSetupHomeModuleSignal.dispatch();
		}

		private function onHomeModuleSetUp() : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.PICK_IMAGE);
			stateMachine.setActiveState(homeState);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyBookModuleSignal.dispatch();
		}
	}
}