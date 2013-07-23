package net.psykosoft.psykopaint2.core.signals
{

	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifyColorStyleCompleteSignal extends Signal
	{
		public function NotifyColorStyleCompleteSignal()
		{
			// we will pass along BitmapData for the next stage
			super(BitmapData);
		}
	}
}
