package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.base.utils.misc.StateStack;
	import net.psykosoft.psykopaint2.core.signals.NotifyStateChangeSignal;

	public class StateModel
	{
		[Inject]
		public var notifyStateChangeSignal:NotifyStateChangeSignal;

		private var _stateStackUtil:StateStack;

		public function StateModel() {
			super();
			_stateStackUtil = new StateStack();
		}

		public function returnToPreviousState():void {
			_stateStackUtil.popState();
			var state:String = currentState;
			trace( this, "state changed: " + state );
			notifyStateChangeSignal.dispatch( state );
		}

		public function set currentState( state:String ):void {
			if( _stateStackUtil.currentState == state ) return; // Dismiss changes to current state.
			_stateStackUtil.pushState( state );
			trace( this, "state changed: " + state + ", stack: "  + _stateStackUtil.stack );
			notifyStateChangeSignal.dispatch( state );
		}

		public function get currentState():String {
			return _stateStackUtil.currentState;
		}

		public function get previousState():String {
			return _stateStackUtil.previousState;
		}

		public function getStateAtIndex( index:uint ):String {
			return _stateStackUtil.stack[ index ];
		}

		public function get numStates():uint {
			return _stateStackUtil.stack.length;
		}

		public function getLastStateOfCategory( categoryName:String ):String {
			var i:uint;
			var len:uint = _stateStackUtil.stack.length;
			for( i = len - 1; i >= 0; i-- ) {
				var state:String = _stateStackUtil.stack[ i ];
				var dump:Array = state.split( "/" );
				if( dump[ 1 ] == categoryName ) {
					return state;
				}
			}
			throw new Error( this, "unable to find last state for required category: " + categoryName );
		}
	}
}
