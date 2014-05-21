package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class RequestNavigationToggleSignal extends Signal
	{
		public function RequestNavigationToggleSignal() {
			super( int, Boolean, Boolean ); // 1 -> show, -1 -> hide, 0 -> negate; false = do not autocenter; true = skip tween
		}
	}
}