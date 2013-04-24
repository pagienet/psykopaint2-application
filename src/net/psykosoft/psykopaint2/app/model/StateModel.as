package net.psykosoft.psykopaint2.app.model
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;

	public class StateModel
	{
		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		private var _currentState:StateVO = new StateVO( ApplicationStateType.IDLE );
		private var _stateStack:Vector.<StateVO>;

		public function StateModel() {
			super();
			_stateStack = new Vector.<StateVO>();
		}

		public function set currentState( value:StateVO ):void {

			if( _currentState == value ) return;

			if( value.name == ApplicationStateType.PREVIOUS_STATE ) {
				if( _stateStack.length > 0 ) {
					var lastIndex:uint = _stateStack.length - 1;
					value = _stateStack[ lastIndex ];
					_stateStack.splice( lastIndex, 1 );
				}
				else {
					return;
				}
			}

			_currentState = value;
			_stateStack.push( _currentState );

			trace( this, "new state: " + value );
			trace( this, "stack: " + _stateStack );

			notifyStateChangedSignal.dispatch( _currentState );
		}

		public function get currentState():StateVO {
			return _currentState;
		}

		public function get previousState():StateVO {
			var lastIndex:uint = _stateStack.length - 1;
			return _stateStack[ lastIndex ];
		}
	}
}
