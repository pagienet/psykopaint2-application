package net.psykosoft.psykopaint2.paint.signals
{
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;

	import org.osflash.signals.Signal;

	public class RequestSetupPaintModuleSignal extends Signal
	{
		public function RequestSetupPaintModuleSignal()
		{
			super(PaintingDataVO);
		}
	}
}
