package net.psykosoft.psykopaint2.app.signal.requests
{

	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class RequestSourceImageChangeSignal extends Signal
	{
		public function RequestSourceImageChangeSignal() {
			super( BitmapData );
		}
	}
}
