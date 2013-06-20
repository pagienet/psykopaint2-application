package net.psykosoft.psykopaint2.base.utils.misc
{

	public class StateStack
	{
		private var _stateStack:Vector.<String>;

		public function StateStack() {
			super();
			_stateStack = new Vector.<String>();
		}

		/*
		 * Adds a state to the end of the stack.
		 */
		public function pushState( state:String ):void {
			_stateStack.push( state );
		}

		/*
		 * Removes the last state from the stack.
		 */
		public function popState():void {
			if( _stateStack.length == 0 ) return; // Empty stack.
			_stateStack.splice( _stateStack.length - 1, 1 );
		}

		public function get currentState():String {
			if( _stateStack.length == 0 ) return ""; // Empty stack.
			return _stateStack[ _stateStack.length - 1 ];
		}

		public function get previousState():String {
			if( _stateStack.length < 2 ) return ""; // Not enough states.
			return _stateStack[ _stateStack.length - 2 ];
		}
	}
}
