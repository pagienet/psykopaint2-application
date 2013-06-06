package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestStateChangeSignal extends TracingSignal
	{
		public function RequestStateChangeSignal() {
			super( String ); // State name.
		}
	}
}
