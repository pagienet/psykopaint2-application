package net.psykosoft.psykopaint2.core.signals
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class RequestSetCanvasSurfaceSignal extends Signal
	{
		public function RequestSetCanvasSurfaceSignal() {
			super( ByteArray, BitmapData ); // normal data, color data
		}
	}
}
