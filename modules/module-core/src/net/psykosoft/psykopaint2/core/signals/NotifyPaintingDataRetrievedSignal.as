package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;

	public class NotifyPaintingDataRetrievedSignal extends TracingSignal
	{
		public function NotifyPaintingDataRetrievedSignal() {
			super( Vector.<PaintingVO> );
		}
	}
}