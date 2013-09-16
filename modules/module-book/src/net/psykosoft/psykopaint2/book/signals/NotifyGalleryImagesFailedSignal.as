package net.psykosoft.psykopaint2.book.signals
{
	import org.osflash.signals.Signal;

	public class NotifyGalleryImagesFailedSignal extends Signal
	{
		public function NotifyGalleryImagesFailedSignal()
		{
			// passing error code
			super(int);
		}
	}
}
