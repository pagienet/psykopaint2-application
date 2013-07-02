package net.psykosoft.psykopaint2.paint.signals {
	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPaintingDeletionSignal extends TracingSignal {
		public function RequestPaintingDeletionSignal() {
			super( String );// Painting id
		}
	}
}
