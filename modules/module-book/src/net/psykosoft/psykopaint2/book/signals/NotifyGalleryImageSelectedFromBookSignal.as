package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import org.osflash.signals.Signal;

	public class NotifyGalleryImageSelectedFromBookSignal extends Signal
	{
		public function NotifyGalleryImageSelectedFromBookSignal()
		{
			super(GalleryImageProxy);
		}
	}
}
