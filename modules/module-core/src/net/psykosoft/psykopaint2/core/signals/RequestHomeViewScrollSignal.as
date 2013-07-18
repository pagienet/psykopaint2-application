package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestHomeViewScrollSignal extends Signal
	{
		public function RequestHomeViewScrollSignal() {
			super( int ); // Index of snap point to scroll to.
		}
	}
}
