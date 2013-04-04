package net.psykosoft.psykopaint2.app.model
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;

	public class StateModel
	{
		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		private var _currentState:StateVO = new StateVO( ApplicationStateType.IDLE );
		private var _previousState:StateVO;

		public function StateModel() {
			super();
		}

		public function set currentState( value:StateVO ):void {

			if( _currentState == value ) return;

			if( value.name == ApplicationStateType.PREVIOUS_STATE ) {
				if( _previousState ) {
					value = _previousState;
					_previousState = null;
					// TODO: implement a state stack instead
				}
				else {
					return;
				}
			}

			Cc.log( this, "new state: " + value );

			_previousState = _currentState;
			_currentState = value;

			notifyStateChangedSignal.dispatch( _currentState );
		}

		public function get currentState():StateVO {
			return _currentState;
		}

		public function get previousState():StateVO {
			return _previousState;
		}
	}
}