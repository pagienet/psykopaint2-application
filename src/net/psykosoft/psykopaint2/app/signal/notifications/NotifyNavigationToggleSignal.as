package net.psykosoft.psykopaint2.app.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyNavigationToggleSignal extends Signal
	{
		public function NotifyNavigationToggleSignal() {
			super( Boolean ); // shown/hidden
		}
	}
}