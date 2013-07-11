package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestNavigationToggleSignal extends Signal
	{
		public function RequestNavigationToggleSignal() {
			super( int, Number ); // 1 -> show, -1 -> hide, 0 -> negate; duration to show/hide
		}
	}
}
