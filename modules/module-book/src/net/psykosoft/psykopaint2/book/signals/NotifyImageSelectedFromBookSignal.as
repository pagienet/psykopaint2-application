package net.psykosoft.psykopaint2.book.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifyImageSelectedFromBookSignal extends Signal
	{
		public function NotifyImageSelectedFromBookSignal()
		{
			super(BitmapData);
		}
	}
}
