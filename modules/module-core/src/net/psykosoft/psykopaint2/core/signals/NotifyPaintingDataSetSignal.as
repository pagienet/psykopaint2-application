package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	public class NotifyPaintingDataSetSignal extends TracingSignal
	{
		public function NotifyPaintingDataSetSignal() {
			super( Vector.<PaintingInfoVO> );
		}
	}
}
