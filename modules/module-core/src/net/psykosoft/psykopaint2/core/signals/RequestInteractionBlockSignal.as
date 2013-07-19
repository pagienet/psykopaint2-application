package net.psykosoft.psykopaint2.core.signals
{

	import net.psykosoft.psykopaint2.base.robotlegs.signals.TracingSignal;

	public class RequestInteractionBlockSignal extends TracingSignal
	{
		public function RequestInteractionBlockSignal() {
			super( Boolean ); // True = shows block sprite above everything, false = hides it
		}
	}
}
