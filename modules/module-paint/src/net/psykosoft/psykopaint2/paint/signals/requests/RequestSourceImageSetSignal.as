package net.psykosoft.psykopaint2.paint.signals.requests
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestSourceImageSetSignal extends TracingSignal
	{
		public function RequestSourceImageSetSignal() {
			super( BitmapData );
		}
	}
}
