 package net.psykosoft.psykopaint2.base.states
{
	 import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	 use namespace ns_state_machine;

	public class State
	{
		private var _stateMachine : StateMachine;

		public function setStateMachine() : void
		{

		}

		public function get stateMachine() : StateMachine
		{
			return _stateMachine;
		}

		public function set stateMachine(value : StateMachine) : void
		{
			_stateMachine = value;
		}

		ns_state_machine function activate() : void
		{
		}

		ns_state_machine function deactivate() : void
		{
		}
	}
}
