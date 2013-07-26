package net.psykosoft.psykopaint2.app.states
{
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintStateSignal;

	use namespace ns_state_machine;

	public class HomeState extends State
	{
		[Inject]
		public var requestNavigationToggleSignal : RequestNavigationToggleSignal;

		[Inject]
		public var requestHomeViewScrollSignal : RequestHomeViewScrollSignal;

		// TODO: REMOVE THIS SIGNAL AND COMMUNICATE DIFFERENTLY?
		[Inject]
		public var requestPaintStateSignal : RequestPaintStateSignal;

		[Inject]
		public var transitionToPaintState : TransitionHomeToPaintState;

		public function HomeState()
		{
		}

		override ns_state_machine function activate() : void
		{
			// TODO: this probably needs to be moved to some activation command
			requestNavigationToggleSignal.dispatch(1, 0.5);
			requestHomeViewScrollSignal.dispatch(1);
			requestPaintStateSignal.add(onRequestPaintStateSignal);
		}

		override ns_state_machine function deactivate() : void
		{
			requestPaintStateSignal.remove(onRequestPaintStateSignal);
		}

		private function onRequestPaintStateSignal() : void
		{
			stateMachine.setActiveState(transitionToPaintState);
		}
	}
}
