package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifySmearStylePresetsAvailableSignal extends Signal
	{
		public function NotifySmearStylePresetsAvailableSignal()
		{
			// we will pass along an Array with the labels for the next stage
			super(Array);
		}
	}
}
