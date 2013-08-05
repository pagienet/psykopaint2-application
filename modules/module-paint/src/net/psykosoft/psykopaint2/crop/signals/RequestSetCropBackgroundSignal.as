package net.psykosoft.psykopaint2.crop.signals
{
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;

	import org.osflash.signals.Signal;

	public class RequestSetCropBackgroundSignal extends Signal
	{
		public function RequestSetCropBackgroundSignal()
		{
			super(RefCountedTexture);
		}
	}
}
