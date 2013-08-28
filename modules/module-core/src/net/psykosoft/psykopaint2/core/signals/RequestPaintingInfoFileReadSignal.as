package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestPaintingInfoFileReadSignal extends Signal
	{
		public function RequestPaintingInfoFileReadSignal() {
			super( String ); // File name.
		}
	}
}
