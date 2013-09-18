package net.psykosoft.psykopaint2.app.states
{

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.book.signals.NotifyAnimateBookOutCompleteSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestAnimateBookOutSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;

	public class TransitionBookToHomeState extends State
	{
		// injected from HomeState due to circular dependency
		public var homeState : HomeState;

		[Inject]
		public var requestDestroyBookModuleSignal : RequestDestroyBookModuleSignal;

		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestAnimateBookOutSignal : RequestAnimateBookOutSignal;

		[Inject]
		public var notifyAnimateBookOutCompleteSignal : NotifyAnimateBookOutCompleteSignal;

		public function TransitionBookToHomeState()
		{
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			notifyAnimateBookOutCompleteSignal.addOnce(onAnimateBookOutComplete);
			requestAnimateBookOutSignal.dispatch();

		}

		private function onAnimateBookOutComplete() : void
		{
			stateMachine.setActiveState(homeState);
			requestStateChangeSignal.dispatch(NavigationStateType.PICK_IMAGE);
		}

		override ns_state_machine function deactivate() : void
		{
			requestDestroyBookModuleSignal.dispatch();
		}
	}
}
