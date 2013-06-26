package net.psykosoft.psykopaint2.paint.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestGoToHomeWithCanvasSnapshotSignal extends TracingSignal
	{
		public function RequestGoToHomeWithCanvasSnapshotSignal() {
			super( String ); // StateType.as - the sub-state of the home module to go to
		}
	}
}
