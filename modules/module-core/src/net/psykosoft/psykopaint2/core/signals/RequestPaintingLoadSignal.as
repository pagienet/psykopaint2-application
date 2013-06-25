package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPaintingLoadSignal extends TracingSignal
	{
		public function RequestPaintingLoadSignal() {
			super( String ); // painting id
		}
	}
}
