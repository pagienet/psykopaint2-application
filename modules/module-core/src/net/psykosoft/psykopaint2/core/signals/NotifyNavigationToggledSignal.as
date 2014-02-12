package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyNavigationToggledSignal extends Signal
	{
		public function NotifyNavigationToggledSignal() {
			super( Boolean ); // True if shown, false if hidden.
		}
	}
}
