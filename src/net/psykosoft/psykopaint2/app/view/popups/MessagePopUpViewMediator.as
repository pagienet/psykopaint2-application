package net.psykosoft.psykopaint2.app.view.popups
{

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;

	public class MessagePopUpViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:MessagePopUpView;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From app.
			notifyPopUpMessageSignal.add( onMessage );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onMessage( value:String ):void {
			view.setMessage( value );
		}
	}
}
