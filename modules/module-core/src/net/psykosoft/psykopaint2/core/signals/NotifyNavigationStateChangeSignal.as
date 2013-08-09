package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyNavigationStateChangeSignal extends TracingSignal
	{
		public function NotifyNavigationStateChangeSignal() {
			super( String ); // New state.
		}
	}
}
