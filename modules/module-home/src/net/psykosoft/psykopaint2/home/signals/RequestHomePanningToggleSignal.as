package net.psykosoft.psykopaint2.home.signals
{

	import org.osflash.signals.Signal;

	public class RequestHomePanningToggleSignal extends Signal
	{
		public function RequestHomePanningToggleSignal() {
			super( Boolean ); // True to allow home view panning, false to not allow it.
		}
	}
}
