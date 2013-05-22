package net.psykosoft.psykopaint2.core.signals.requests
{
	import net.psykosoft.psykopaint2.base.robotlegs.BsTracingSignal;

	public class CrRequestStateChangeSignal extends BsTracingSignal
	{
		public function CrRequestStateChangeSignal() {
			super( String ); // State name.
		}
	}
}
