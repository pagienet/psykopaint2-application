package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestUpdateMessagePopUpSignal extends Signal
	{
		public function RequestUpdateMessagePopUpSignal() {
			super( String, String ); // Title and Message to be displayed in the pop up.
		}
	}
}
