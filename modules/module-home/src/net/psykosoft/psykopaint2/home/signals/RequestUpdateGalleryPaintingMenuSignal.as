package net.psykosoft.psykopaint2.home.signals
{
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import org.osflash.signals.Signal;

	public class RequestUpdateGalleryPaintingMenuSignal extends Signal
	{
		public function RequestUpdateGalleryPaintingMenuSignal()
		{
			super(GalleryImageProxy);
		}
	}
}
