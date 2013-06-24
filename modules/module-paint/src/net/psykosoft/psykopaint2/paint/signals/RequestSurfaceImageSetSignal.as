package net.psykosoft.psykopaint2.paint.signals
{
	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class RequestSurfaceImageSetSignal extends Signal
	{
		public function RequestSurfaceImageSetSignal() {
			super( ByteArray );
		}
	}
}
