package net.psykosoft.psykopaint2.core.signals
{

	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	public class RequestCameraAdjustToRectSignal extends Signal
	{
		public function RequestCameraAdjustToRectSignal() {
			super( Rectangle ); // Home view camera will adjust it's z value so that it fits the easel within this screen rect.
		}
	}
}
