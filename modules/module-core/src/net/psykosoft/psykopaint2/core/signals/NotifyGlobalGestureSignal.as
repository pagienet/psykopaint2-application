package net.psykosoft.psykopaint2.core.signals
{
	import org.gestouch.events.GestureEvent;
	import org.osflash.signals.Signal;

	public class NotifyGlobalGestureSignal extends Signal
	{
		public function NotifyGlobalGestureSignal() {
			super( String, GestureEvent ); // Gesture name from GestureType.as
		}
	}
}
