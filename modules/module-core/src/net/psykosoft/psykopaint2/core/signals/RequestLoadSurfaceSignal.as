package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestLoadSurfaceSignal extends TracingSignal
	{
		public function RequestLoadSurfaceSignal() {
			super( uint ); // The index of the surface in the packaged assets folder.
		}
	}
}
