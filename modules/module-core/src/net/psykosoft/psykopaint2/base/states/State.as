 package net.psykosoft.psykopaint2.base.states
{
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

		/**
		 * @param data Optional data structure needed to be passed in through StateMachine:setActiveState
		 * PLEASE, if needed, document the type in subclasses
		 */
		ns_state_machine function activate(data : Object = null) : void
		{
		}

		ns_state_machine function deactivate() : void
		{
		}
	}
}
