package net.psykosoft.psykopaint2.app.signal.requests
{

	import org.osflash.signals.Signal;

	public class RequestReadyToPaintImageSignal extends Signal
	{
		public function RequestReadyToPaintImageSignal() {
			super( String ); // Image name or id.
		}
	}
}
