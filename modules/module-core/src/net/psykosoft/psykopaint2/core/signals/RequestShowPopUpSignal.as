package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class RequestShowPopUpSignal extends Signal
	{
		public function RequestShowPopUpSignal() {
			super( String ); // PopUpType.as
		}
	}
}
