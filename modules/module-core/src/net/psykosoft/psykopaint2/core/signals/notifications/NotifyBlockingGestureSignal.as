package net.psykosoft.psykopaint2.core.signals.notifications
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyBlockingGestureSignal extends TracingSignal
	{
		public function NotifyBlockingGestureSignal() {
			super( Boolean ); // true if gesture has started, false if gesture has ended
		}
	}
}
