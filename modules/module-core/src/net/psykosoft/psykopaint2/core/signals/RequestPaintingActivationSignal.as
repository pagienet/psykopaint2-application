package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPaintingActivationSignal extends TracingSignal
	{
		public function RequestPaintingActivationSignal() {
			super( String ); // painting id
		}
	}
}
