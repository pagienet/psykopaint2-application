package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPopUpDisplaySignal extends TracingSignal
	{
		public function RequestPopUpDisplaySignal() {
			super( String ); // PopUpType.as
		}
	}
}
