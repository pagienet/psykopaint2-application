package net.psykosoft.psykopaint2.core.signals
{
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;

	import org.osflash.signals.Signal;

	public class RequestSetCanvasBackgroundSignal extends Signal
	{
		public function RequestSetCanvasBackgroundSignal()
		{
			super(RefCountedTexture);
		}
	}
}
