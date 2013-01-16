package net.psykosoft.psykopaint2.model.state
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;

	public class StateModel
	{
		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		private var _currentState:StateVO = new StateVO( States.SPLASH_SCREEN );
		private var _previousState:StateVO;

		public function StateModel() {
			super();
		}

		public function set currentState( value:StateVO ):void {

			if( _currentState == value ) return;

			if( value.name == States.PREVIOUS_STATE ) {
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
