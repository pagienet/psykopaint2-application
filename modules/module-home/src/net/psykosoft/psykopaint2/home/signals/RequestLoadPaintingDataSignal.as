package net.psykosoft.psykopaint2.home.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestLoadPaintingDataSignal extends TracingSignal
	{
		public function RequestLoadPaintingDataSignal() {
			super( String ); // painting id
		}
	}
}
