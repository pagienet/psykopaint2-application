package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	public class RequestEaselUpdateSignal extends TracingSignal
	{
		public function RequestEaselUpdateSignal() {
			super( PaintingInfoVO, Boolean, Function ); // Painting data, Boolean to use or not use animation, Function that will be called when PaintingVO is no longer needed for actions resulting in this callback (allows disposal)
		}
	}
}
