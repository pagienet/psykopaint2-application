package net.psykosoft.psykopaint2.signal.notifications
{

	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifySourceImagesUpdatedSignal extends Signal
	{
		public function NotifySourceImagesUpdatedSignal() {
			super( Vector.<BitmapData> );
		}
	}
}
