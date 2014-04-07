package net.psykosoft.psykopaint2.app.signals
{
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;

	import org.osflash.signals.Signal;

	public class NotifyFrozenBackgroundCreatedSignal extends Signal
	{
		public function NotifyFrozenBackgroundCreatedSignal()
		{
			super(RefCountedRectTexture);
		}
	}
}
