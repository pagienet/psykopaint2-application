package net.psykosoft.psykopaint2.book.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifySourceImageSelectedFromBookSignal extends Signal
	{
		public function NotifySourceImageSelectedFromBookSignal()
		{
			super(BitmapData);
		}
	}
}
