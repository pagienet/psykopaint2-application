package net.psykosoft.psykopaint2.base.states
{
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

		public function activate() : void
		{
		}

		public function deactivate() : void
		{
		}
	}
}
