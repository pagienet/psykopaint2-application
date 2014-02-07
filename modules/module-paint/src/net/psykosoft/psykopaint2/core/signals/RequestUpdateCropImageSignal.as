package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class RequestUpdateCropImageSignal extends Signal
	{
		public function RequestUpdateCropImageSignal()
		{
			super(BitmapData, int);
		}
	}
}
