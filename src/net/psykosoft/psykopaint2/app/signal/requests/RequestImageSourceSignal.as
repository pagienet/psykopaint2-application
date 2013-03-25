package net.psykosoft.psykopaint2.app.signal.requests
{

	import org.osflash.signals.Signal;

	public class RequestImageSourceSignal extends Signal
	{
		public function RequestImageSourceSignal() {
			super( String ); // of type ImageSourceType
		}
	}
}
