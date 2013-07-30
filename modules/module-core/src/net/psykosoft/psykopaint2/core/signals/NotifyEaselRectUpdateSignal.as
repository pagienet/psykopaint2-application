package net.psykosoft.psykopaint2.core.signals
{
	import flash.geom.Rectangle;

	import org.osflash.signals.Signal;

	public class NotifyEaselRectUpdateSignal extends Signal
	{
		public function NotifyEaselRectUpdateSignal()
		{
			super(Rectangle);
		}
	}
}
