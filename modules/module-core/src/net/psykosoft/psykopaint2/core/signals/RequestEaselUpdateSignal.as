package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	public class RequestEaselUpdateSignal extends TracingSignal
	{
		public function RequestEaselUpdateSignal() {
			super( PaintingInfoVO, Boolean, Boolean ); // Painting data, Boolean to use or not use animation, Boolean to discard vo when finished animation
		}
	}
}
