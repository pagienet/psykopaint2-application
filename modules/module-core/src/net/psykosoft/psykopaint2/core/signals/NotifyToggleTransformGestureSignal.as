package net.psykosoft.psykopaint2.core.signals
{

	import org.osflash.signals.Signal;

	public class NotifyToggleTransformGestureSignal extends Signal
	{
		public function NotifyToggleTransformGestureSignal() {
			super( Boolean ); // true = enabled
		}
	}
}
