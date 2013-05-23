package net.psykosoft.psykopaint2.core.signals.notifications
{

	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingSignal;

	public class CrNotifyNavigationToggledSignal extends BsTracingSignal
	{
		public function CrNotifyNavigationToggledSignal() {
			super( Boolean ); // True if shown, false if hidden.
		}
	}
}
