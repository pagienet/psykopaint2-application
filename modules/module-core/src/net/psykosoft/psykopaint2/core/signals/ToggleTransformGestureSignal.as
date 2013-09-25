package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class ToggleTransformGestureSignal extends Signal
	{
		public function ToggleTransformGestureSignal() {
			super( Boolean ); // true = enabled
		}
	}
}
