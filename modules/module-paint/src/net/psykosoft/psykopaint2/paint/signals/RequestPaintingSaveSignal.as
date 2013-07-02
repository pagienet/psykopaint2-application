package net.psykosoft.psykopaint2.paint.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPaintingSaveSignal extends TracingSignal
	{
		public function RequestPaintingSaveSignal() {
			super( String, Boolean ); // Painting id, update easel
		}
	}
}
