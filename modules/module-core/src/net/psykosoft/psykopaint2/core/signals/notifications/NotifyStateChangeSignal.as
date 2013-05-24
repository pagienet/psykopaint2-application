package net.psykosoft.psykopaint2.core.signals.notifications
{
	import net.psykosoft.psykopaint2.base.robotlegs.TracingSignal;

	public class NotifyStateChangeSignal extends TracingSignal
	{
		public function NotifyStateChangeSignal() {
			super( String ); // New state.
		}
	}
}
