package net.psykosoft.psykopaint2.app.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyGlobalGestureSignal extends Signal
	{
		public function NotifyGlobalGestureSignal() {
			super( uint ); // Must be a static parameter of GestureType.as
		}
	}
}
