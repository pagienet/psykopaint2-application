package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyPaintingInfoSavedSignal extends TracingSignal
	{
		public function NotifyPaintingInfoSavedSignal() {
			super( Boolean ); // Success
		}
	}
}
