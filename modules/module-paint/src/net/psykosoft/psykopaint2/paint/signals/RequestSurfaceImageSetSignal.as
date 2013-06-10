package net.psykosoft.psykopaint2.paint.signals
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestSurfaceImageSetSignal extends TracingSignal
	{
		public function RequestSurfaceImageSetSignal() {
			super( BitmapData );
		}
	}
}
