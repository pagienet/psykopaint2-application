package net.psykosoft.psykopaint2.home.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestZoomThenChangeStateSignal extends TracingSignal
	{
		public function RequestZoomThenChangeStateSignal() {
			super( Boolean, String ); // Boolean: true = zoom in, false = zoom out, String: StateType
		}
	}
}
