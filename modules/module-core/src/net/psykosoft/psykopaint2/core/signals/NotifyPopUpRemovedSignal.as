package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyPopUpRemovedSignal extends TracingSignal
	{
		public function NotifyPopUpRemovedSignal() {
			super(); // No params, simply notifies when any pop up has been removed.
		}
	}
}
