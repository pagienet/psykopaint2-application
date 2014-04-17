package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestUpdateErrorPopUpSignal extends Signal
	{
		public function RequestUpdateErrorPopUpSignal() {
			super( String, String ); // Title and Message to be displayed in the pop up.
		}
	}
}
