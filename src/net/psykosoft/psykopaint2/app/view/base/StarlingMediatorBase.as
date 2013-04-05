package net.psykosoft.psykopaint2.app.view.base
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class StarlingMediatorBase extends StarlingMediator
	{
		[Inject]
		public var notifyOSMemoryWarningSignal:NotifyMemoryWarningSignal;

		[Inject]
		public var notifyApplicationStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var requestApplicationStateChangeSignal:RequestStateChangeSignal;

		private var _enablingStates:Vector.<String>;
		private var _view:IApplicationView;
		private var _manageStateChanges:Boolean = true;
		private var _manageMemoryWarnings:Boolean = true;

		override public function initialize():void {

			_enablingStates = new Vector.<String>();

			notifyOSMemoryWarningSignal.add( onMemoryWarning );
			notifyApplicationStateChangedSignal.add( onStateChange );
		}

		protected function registerEnablingState( stateName:String ):void {
			_enablingStates.push( stateName );
		}

		protected function requestStateChange( vo:StateVO ):void {
			requestApplicationStateChangeSignal.dispatch( vo );
		}

		protected function onStateChange( newStateName:String ):void {
//			trace( this, "state change: " + newStateName );
			if( !_manageStateChanges ) return;
			var isViewEnabled:Boolean = _enablingStates.indexOf( newStateName ) != -1;
			if( isViewEnabled ) _view.enable();
			else _view.disable();
		}

		protected function onMemoryWarning():void {
//			trace( this, "memory warning" );
			if( !_manageMemoryWarnings ) return;
			if( !_view.enabled ) _view.dispose();
		}

		protected function registerView( value:IApplicationView ):void {
			_view = value;
		}

		public function get manageStateChanges():Boolean {
			return _manageStateChanges;
		}

		public function set manageStateChanges( value:Boolean ):void {
			_manageStateChanges = value;
		}

		public function get manageMemoryWarnings():Boolean {
			return _manageMemoryWarnings;
		}

		public function set manageMemoryWarnings( value:Boolean ):void {
			_manageMemoryWarnings = value;
		}
	}
}
