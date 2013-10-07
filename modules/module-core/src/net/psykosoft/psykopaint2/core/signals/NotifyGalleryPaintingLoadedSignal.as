package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.PaintingGalleryVO;

	import org.osflash.signals.Signal;

	public class NotifyGalleryPaintingLoadedSignal extends Signal
	{
		public function NotifyGalleryPaintingLoadedSignal()
		{
			// GalleryImageProxy: the gallery image proxy containing the data and providing access to its painting data
			super(GalleryImageProxy, BitmapData);
		}
	}
}
