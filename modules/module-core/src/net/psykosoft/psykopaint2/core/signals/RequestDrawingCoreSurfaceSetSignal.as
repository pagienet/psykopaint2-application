package net.psykosoft.psykopaint2.core.signals
{

	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class RequestDrawingCoreSurfaceSetSignal extends Signal
	{
		public function RequestDrawingCoreSurfaceSetSignal() {
			super( ByteArray );
		}
	}
}
