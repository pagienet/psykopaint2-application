package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestZoomToggleSignal extends TracingSignal
	{
		public function RequestZoomToggleSignal() {
			super( Boolean ); // true = zoom in, false = zoom out
		}
	}
}
