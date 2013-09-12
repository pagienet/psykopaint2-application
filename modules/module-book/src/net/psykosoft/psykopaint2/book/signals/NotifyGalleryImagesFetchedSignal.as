package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.book.model.GalleryImageCollection;

	import org.osflash.signals.Signal;

	public class NotifyGalleryImagesFetchedSignal extends Signal
	{
		public function NotifyGalleryImagesFetchedSignal()
		{
			super(GalleryImageCollection);
		}
	}
}
