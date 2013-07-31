package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyPaintingSavedSignal extends TracingSignal
	{
		public function NotifyPaintingSavedSignal() {
			super( Boolean ); // Success
		}
	}
}
