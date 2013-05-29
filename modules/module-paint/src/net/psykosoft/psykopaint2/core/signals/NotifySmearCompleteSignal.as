package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifySmearCompleteSignal extends Signal
	{
		public function NotifySmearCompleteSignal()
		{
			// we will pass along BitmapData for the next stage
			super(BitmapData);
		}
	}
}
