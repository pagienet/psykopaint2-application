package net.psykosoft.psykopaint2.home.signals
{
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;

	import org.osflash.signals.Signal;

	public class NotifyPaintingDataLoadedSignal extends Signal
	{
		public function NotifyPaintingDataLoadedSignal()
		{
			super(PaintingDataVO);
		}
	}
}
