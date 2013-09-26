package net.psykosoft.psykopaint2.book.signals
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageRequestVO;

	import org.osflash.signals.Signal;

	public class RequestFetchGalleryImagesSignal extends Signal
	{
		public function RequestFetchGalleryImagesSignal()
		{
			super(GalleryImageRequestVO);
		}
	}
}
