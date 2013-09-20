package net.psykosoft.psykopaint2.home.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestLoadPaintingDataFileSignal extends TracingSignal
	{
		public function RequestLoadPaintingDataFileSignal() {
			super( String ); // painting id
		}
	}
}
