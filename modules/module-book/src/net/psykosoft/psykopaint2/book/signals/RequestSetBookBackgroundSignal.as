package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;

	import org.osflash.signals.Signal;

	public class RequestSetBookBackgroundSignal extends Signal
	{
		public function RequestSetBookBackgroundSignal()
		{
			super(RefCountedTexture);
		}
	}
}
