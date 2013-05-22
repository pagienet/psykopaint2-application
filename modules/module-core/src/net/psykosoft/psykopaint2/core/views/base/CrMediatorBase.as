package net.psykosoft.psykopaint2.core.views.base
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.base.ui.BsViewBase;

	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.CrRequestStateChangeSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CrMediatorBase extends Mediator
	{
//		[Inject]
//		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal; // TODO: reconnect

		[Inject]
		public var notifyStateChangeSignal:CrNotifyStateChangeSignal;

		[Inject]
		public var requestStateChangeSignal:CrRequestStateChangeSignal;

		private var _enablingStates:Vector.<String>;
		private var _view:BsViewBase;

		public var manageStateChanges:Boolean = true;
		public var manageMemoryWarnings:Boolean = true;

		override public function initialize():void {

			Cc.log( this, "initialize" );

			_enablingStates = new Vector.<String>();

//			notifyMemoryWarningSignal.add( onMemoryWarning );
			notifyStateChangeSignal.add( onStateChange );
		}

		protected function registerView( value:BsViewBase ):void {
			_view = value;
		}

		protected function registerEnablingState( state:String ):void {
			_enablingStates.push( state );
		}

		protected function requestStateChange( state:String ):void {
			requestStateChangeSignal.dispatch( state );
		}

		protected function onStateChange( newState:String ):void {
			if( !manageStateChanges ) return;
			var isViewEnabled:Boolean = _enablingStates.indexOf( newState ) != -1;
			if( isViewEnabled ) _view.enable();
			else _view.disable();
		}

		protected function onMemoryWarning():void {
			if( !manageMemoryWarnings ) return;
			if( !_view.visible ) _view.dispose();
		}
	}
}
