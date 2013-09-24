package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyPaintingDataSavedSignal extends Signal
	{
		public function NotifyPaintingDataSavedSignal() {
			super( Boolean ); // Success
		}
	}
}
