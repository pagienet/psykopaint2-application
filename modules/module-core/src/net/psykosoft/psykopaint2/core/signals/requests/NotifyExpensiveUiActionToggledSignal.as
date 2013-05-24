package net.psykosoft.psykopaint2.core.signals.requests
{

	import org.osflash.signals.Signal;

	public class NotifyExpensiveUiActionToggledSignal extends Signal
	{
		public function NotifyExpensiveUiActionToggledSignal() {
			// Boolean: true if the activity started, false if it ended
			// String: an id for the activity
			super( Boolean, String );
		}
	}
}
