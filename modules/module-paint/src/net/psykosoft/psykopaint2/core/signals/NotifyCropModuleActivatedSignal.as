package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifyCropModuleActivatedSignal extends Signal
	{
		public function NotifyCropModuleActivatedSignal()
		{
			super(BitmapData);
		}
	}
}
