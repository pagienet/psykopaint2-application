package net.psykosoft.psykopaint2.app.signal.requests
{

	import org.osflash.signals.Signal;

	public class RequestFullImageSignal extends Signal
	{
		public function RequestFullImageSignal() {
			super( String ); // Image name or id.
		}
	}
}
