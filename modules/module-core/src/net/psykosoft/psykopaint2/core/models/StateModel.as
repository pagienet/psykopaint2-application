package net.psykosoft.psykopaint2.core.models
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.base.utils.StateStack;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyStateChangeSignal;

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
			Cc.log( this, "state changed: " + state );
			notifyStateChangeSignal.dispatch( state );
		}

		public function set currentState( state:String ):void {
			if( _stateStackUtil.currentState == state ) return; // Dismiss changes to current state.
			_stateStackUtil.pushState( state );
			Cc.log( this, "state changed: " + state );
			notifyStateChangeSignal.dispatch( state );
		}

		public function get currentState():String {
			return _stateStackUtil.currentState;
		}
	}
}
