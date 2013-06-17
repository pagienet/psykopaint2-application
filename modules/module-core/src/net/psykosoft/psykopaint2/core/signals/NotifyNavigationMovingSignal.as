package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyNavigationMovingSignal extends Signal
	{
		public function NotifyNavigationMovingSignal() {
			super( Number ); // 0 is open, 1 is closed, with all in between values.
		}
	}
}
