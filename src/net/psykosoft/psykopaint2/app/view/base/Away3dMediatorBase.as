package net.psykosoft.psykopaint2.app.view.base
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class Away3dMediatorBase extends Mediator
	{
		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		private var _enablingStates:Vector.<String>;
		private var _view:IApplicationView;

		override public function initialize():void {

			_enablingStates = new Vector.<String>();

			notifyMemoryWarningSignal.add( onMemoryWarning );
			notifyStateChangedSignal.add( onStateChange );
		}

		protected function registerEnablingState( stateName:String ):void {
			_enablingStates.push( stateName );
		}

		protected function requestStateChange( vo:StateVO ):void {

		}

		protected function onStateChange( newStateName:String ):void {
			trace( this, "state change: " + newStateName );

			var isViewEnabled:Boolean = _enablingStates.indexOf( newStateName ) != -1;
			if( isViewEnabled ) _view.enable();
			else _view.disable();
		}

		protected function onMemoryWarning():void {
			trace( this, "memory warning" );
			if( !_view.enabled ) _view.dispose();
		}

		protected function registerView( value:IApplicationView ):void {
			_view = value;
		}
	}
}
