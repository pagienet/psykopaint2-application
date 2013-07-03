package net.psykosoft.psykopaint2.paint.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPaintingDeactivationSignal extends TracingSignal
	{
		public function RequestPaintingDeactivationSignal() {
			super( String ); // painting id
		}
	}
}
