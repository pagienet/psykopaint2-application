package net.psykosoft.psykopaint2.app.signal.notifications
{

	import org.osflash.signals.Signal;

	public class NotifyFocusedPaintingChangedSignal extends Signal
	{
		public function NotifyFocusedPaintingChangedSignal() {
			super( String ); // Painting name.
		}
	}
}
