package net.psykosoft.psykopaint2.core.signals.notifications
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyExpensiveUiActionToggledSignal extends TracingSignal
	{
		public function NotifyExpensiveUiActionToggledSignal() {
			// Boolean: true if the activity started, false if it ended
			// String: an id for the activity
			super( Boolean, String );
		}
	}
}
