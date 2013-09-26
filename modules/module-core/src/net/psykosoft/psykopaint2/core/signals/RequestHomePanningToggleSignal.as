package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestHomePanningToggleSignal extends Signal
	{
		public function RequestHomePanningToggleSignal() {
			super( int ); // 1 to allow home view panning, -1 to not allow it and 0 to restore whatever it was before not allowing it.
		}
	}
}
