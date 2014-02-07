package net.psykosoft.psykopaint2.crop.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class RequestSetupCropModuleSignal extends Signal
	{
		public function RequestSetupCropModuleSignal()
		{
			super(BitmapData,int);
		}
	}
}
