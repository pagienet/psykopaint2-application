package net.psykosoft.psykopaint2.home.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;

	public class RequestEaselPaintingUpdateSignal extends TracingSignal
	{
		public function RequestEaselPaintingUpdateSignal() {
			super( PaintingVO );
		}
	}
}
