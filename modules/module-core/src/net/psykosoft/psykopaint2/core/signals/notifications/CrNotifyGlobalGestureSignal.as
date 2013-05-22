package net.psykosoft.psykopaint2.core.signals.notifications
{
	import org.osflash.signals.Signal;

	public class CrNotifyGlobalGestureSignal extends Signal
	{
		public function CrNotifyGlobalGestureSignal() {
			super( String ); // Gesture name from GestureType.as
		}
	}
}
