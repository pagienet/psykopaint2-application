package net.psykosoft.psykopaint2.model
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.data.States;
	import net.psykosoft.psykopaint2.model.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyStateChangedSignal;

	public class StateModel
	{
		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		private var _currentState:StateVO = new StateVO( States.SPLASH_SCREEN );

		public function StateModel() {
			super();
		}

		public function set state( value:StateVO ):void {
			if( _currentState == value ) return;
			Cc.info( this, "new state: " + value );
			_currentState = value;
			notifyStateChangedSignal.dispatch( _currentState );
		}
	}
}
