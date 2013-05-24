package net.psykosoft.psykopaint2.core.signals.requests
{
	import net.psykosoft.psykopaint2.base.robotlegs.TracingSignal;

	public class RequestStateChangeSignal extends TracingSignal
	{
		public function RequestStateChangeSignal() {
			super( String ); // State name.
		}
	}
}
