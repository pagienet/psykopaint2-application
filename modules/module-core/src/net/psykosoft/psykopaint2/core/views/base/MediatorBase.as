package net.psykosoft.psykopaint2.core.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal_OLD_TO_REMOVE;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class MediatorBase extends Mediator
	{
		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		[Inject]
		public var notifyStateChangeSignal:NotifyStateChangeSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal_OLD_TO_REMOVE;

		private var _enablingStates:Vector.<String>;
		private var _view:ViewBase;

		public var manageStateChanges:Boolean = true;
		public var manageMemoryWarnings:Boolean = true;

		override public function initialize():void {

			trace( this, "initialize" );

			_enablingStates = new Vector.<String>();

			notifyMemoryWarningSignal.add( onMemoryWarning );
			notifyStateChangeSignal.add( onStateChange );
		}

		protected function registerView( value:ViewBase ):void {
			_view = value;
		}

		protected function registerEnablingState( state:String ):void {
			_enablingStates.push( state );
		}

		protected function requestStateChange__OLD_TO_REMOVE( state:String ):void {
			requestStateChangeSignal.dispatch( state );
		}

		protected function onStateChange( newState:String ):void {
			if( !manageStateChanges ) return;
			var isViewEnabled:Boolean = _enablingStates.indexOf( newState ) != -1;
			if( isViewEnabled ) _view.enable();
			else _view.disable();
		}

		protected function onMemoryWarning():void {
			trace( this, "received memory warning." );
			if( !manageMemoryWarnings ) return;
			if( !_view.visible ) _view.dispose();
		}
	}
}
