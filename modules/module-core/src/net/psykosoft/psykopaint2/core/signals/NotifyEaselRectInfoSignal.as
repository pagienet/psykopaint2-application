package net.psykosoft.psykopaint2.core.signals
{

	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	public class NotifyEaselRectInfoSignal extends Signal
	{
		public function NotifyEaselRectInfoSignal() {
			super( Rectangle );
		}
	}
}
