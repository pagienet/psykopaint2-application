package net.psykosoft.psykopaint2.core.signals.notifications
{
	import org.osflash.signals.Signal;

	public class NotifyGlobalGestureSignal extends Signal
	{
		public function NotifyGlobalGestureSignal() {
			super( String ); // Gesture name from GestureType.as
		}
	}
}
