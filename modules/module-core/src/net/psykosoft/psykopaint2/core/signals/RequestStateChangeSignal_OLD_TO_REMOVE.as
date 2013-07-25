package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestStateChangeSignal_OLD_TO_REMOVE extends TracingSignal
	{
		public function RequestStateChangeSignal_OLD_TO_REMOVE() {
			super( String ); // State name.
		}
	}
}
