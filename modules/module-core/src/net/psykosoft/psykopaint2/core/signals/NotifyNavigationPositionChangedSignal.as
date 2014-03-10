package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyNavigationPositionChangedSignal extends Signal
	{
		public function NotifyNavigationPositionChangedSignal() {
			super( Number ); // offset of navigation position
		}
	}
}
