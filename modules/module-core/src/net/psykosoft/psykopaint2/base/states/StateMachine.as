package net.psykosoft.psykopaint2.base.states
{
	public class StateMachine
	{
		private var _activeState : State;

		public function StateMachine()
		{
		}

		public function setActiveState(state : State) : void
		{
			if (_activeState) {
				_activeState.deactivate();
				_activeState.stateMachine = null;
			}

			_activeState = state;

			if (_activeState) {
				_activeState.stateMachine = this;
				_activeState.activate();
			}
		}
	}
}
