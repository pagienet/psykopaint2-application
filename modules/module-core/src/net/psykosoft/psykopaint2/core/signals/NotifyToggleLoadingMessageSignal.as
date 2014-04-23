package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyToggleLoadingMessageSignal extends Signal
	{
		public function NotifyToggleLoadingMessageSignal() {
			super( Boolean ); // true = show
		}
	}
}
