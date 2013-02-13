package net.psykosoft.psykopaint2.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyNavigationPanelToggle extends Signal
	{
		public function NotifyNavigationPanelToggle() {
			super( Boolean ); // show/hide boolean
		}
	}
}
