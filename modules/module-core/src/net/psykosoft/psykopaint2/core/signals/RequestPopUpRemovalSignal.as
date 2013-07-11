package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestPopUpRemovalSignal extends TracingSignal
	{
		public function RequestPopUpRemovalSignal() {
			super(); // No params, will remove any active pop ups.
		}
	}
}
