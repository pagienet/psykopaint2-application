package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class NotifyNavigationToggledSignal extends TracingSignal
	{
		public function NotifyNavigationToggledSignal() {
			super( Boolean ); // True if shown, false if hidden.
		}
	}
}
