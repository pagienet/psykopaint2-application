package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifyColorStyleModuleActivatedSignal extends Signal
	{
		public function NotifyColorStyleModuleActivatedSignal()
		{
			super(BitmapData);
		}
	}
}
