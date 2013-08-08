package net.psykosoft.psykopaint2.base.states
{
	use namespace ns_state_machine;

	public class StateMachine
	{
		private var _activeState : State;

		public function StateMachine()
		{
		}

		public function setActiveState(state : State, data : Object = null) : void
		{
			if (_activeState) {
				trace ("Deactivating state: " + _activeState);
				_activeState.deactivate();
				_activeState.stateMachine = null;
			}

			_activeState = state;

			if (_activeState) {
				trace ("Activating state: " + _activeState);
				_activeState.stateMachine = this;
				_activeState.activate(data);
			}
		}
	}
}
