package net.psykosoft.psykopaint2.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyPopUpMessageSignal extends Signal
	{
		public function NotifyPopUpMessageSignal() {
			super( String ); // Message.
		}
	}
}
