package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import org.osflash.signals.Signal;

	public class NotifyProfilePictureUpdatedSignal extends Signal
	{
		public function NotifyProfilePictureUpdatedSignal()
		{
			super(BitmapData);
		}
	}
}
