package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyTogglePaintingEnableSignal extends Signal
	{
		public function NotifyTogglePaintingEnableSignal()
		{
			// enable/disable painting
			super(Boolean);
		}
	}
}
