package net.psykosoft.psykopaint2.core.signals
{
	import org.osflash.signals.Signal;

	public class NotifyGalleryServiceCallFailedSignal extends Signal
	{
		public function NotifyGalleryServiceCallFailedSignal()
		{
			super(uint);	// status code of AMFErrorCode
		}
	}
}
