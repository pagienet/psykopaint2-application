package net.psykosoft.psykopaint2.home.commands
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestLoadSurfacePreviewSignal extends TracingSignal
	{
		public function RequestLoadSurfacePreviewSignal() {
			super( uint ); // The index of the surface in the packaged assets folder.
		}
	}
}
