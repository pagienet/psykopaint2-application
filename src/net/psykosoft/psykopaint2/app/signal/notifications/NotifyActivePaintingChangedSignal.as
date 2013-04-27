package net.psykosoft.psykopaint2.app.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyActivePaintingChangedSignal extends Signal
	{
		public function NotifyActivePaintingChangedSignal() {
			super( String ); // Painting name, for now...
		}
	}
}
