package net.psykosoft.psykopaint2.view.starling.popups
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpMessageSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class MessagePopUpViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:MessagePopUpView;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		override public function initialize():void {

			// From app.
			notifyPopUpMessageSignal.add( onMessage );

			super.initialize();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onMessage( value:String ):void {
			view.setMessage( value );
		}
	}
}
