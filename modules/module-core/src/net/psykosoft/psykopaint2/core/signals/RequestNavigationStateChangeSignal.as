package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestNavigationStateChangeSignal extends TracingSignal
	{
		public function RequestNavigationStateChangeSignal() {
			super( String ); // State name.
		}
	}
}
