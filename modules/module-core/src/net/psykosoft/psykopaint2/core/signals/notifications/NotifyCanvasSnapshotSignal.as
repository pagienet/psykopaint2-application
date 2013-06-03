package net.psykosoft.psykopaint2.core.signals.notifications
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyCanvasSnapshotSignal extends TracingSignal
	{
		public function NotifyCanvasSnapshotSignal() {
			super( BitmapData ); // Current state of the canvas.
		}
	}
}
