package net.psykosoft.psykopaint2.app.signal.requests
{

	import org.osflash.signals.Signal;

	public class RequestActivePaintingChangeSignal extends Signal
	{
		public function RequestActivePaintingChangeSignal() {
			super( String ); // Painting name.
		}
	}
}
