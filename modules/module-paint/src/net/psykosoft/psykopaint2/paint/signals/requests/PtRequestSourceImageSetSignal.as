package net.psykosoft.psykopaint2.paint.signals.requests
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingSignal;

	public class PtRequestSourceImageSetSignal extends BsTracingSignal
	{
		public function PtRequestSourceImageSetSignal() {
			super( BitmapData );
		}
	}
}
