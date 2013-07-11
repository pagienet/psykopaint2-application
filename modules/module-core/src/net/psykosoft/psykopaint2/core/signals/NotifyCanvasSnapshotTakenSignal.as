package net.psykosoft.psykopaint2.core.signals
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyCanvasSnapshotTakenSignal extends TracingSignal
	{
		public function NotifyCanvasSnapshotTakenSignal() {
			super( BitmapData ); // Current state of the canvas.
		}
	}
}
