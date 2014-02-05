package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyToggleSwipeGestureSignal extends Signal
	{
		public function NotifyToggleSwipeGestureSignal() {
			super( Boolean ); // true = enabled
		}
	}
}
