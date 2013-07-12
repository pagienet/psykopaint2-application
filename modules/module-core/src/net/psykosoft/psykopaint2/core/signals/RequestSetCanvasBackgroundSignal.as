package net.psykosoft.psykopaint2.core.signals
{
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedBitmapData;

	import org.osflash.signals.Signal;

	public class RequestSetCanvasBackgroundSignal extends Signal
	{
		public function RequestSetCanvasBackgroundSignal()
		{
			super(RefCountedBitmapData);
		}
	}
}
