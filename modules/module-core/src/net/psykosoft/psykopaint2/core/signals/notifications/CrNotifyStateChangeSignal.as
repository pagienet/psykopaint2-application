package net.psykosoft.psykopaint2.core.signals.notifications
{
	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingSignal;

	public class CrNotifyStateChangeSignal extends BsTracingSignal
	{
		public function CrNotifyStateChangeSignal() {
			super( String ); // New state.
		}
	}
}
