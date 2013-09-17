package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.book.model.GalleryImageProxy;

	import org.osflash.signals.Signal;

	public class NotifyGalleryImageSelected extends Signal
	{
		public function NotifyGalleryImageSelected()
		{
			super(GalleryImageProxy);
		}
	}
}
