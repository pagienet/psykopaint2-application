package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;

	import org.osflash.signals.Signal;

	public class NotifyPaintingInfoFileReadSignal extends Signal
	{
		public function NotifyPaintingInfoFileReadSignal() {
			super( PaintingInfoVO );
		}
	}
}
