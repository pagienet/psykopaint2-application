package net.psykosoft.psykopaint2.core.signals
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import org.osflash.signals.Signal;

	public class NotifyGalleryPaintingLoadedSignal extends Signal
	{
		public function NotifyGalleryPaintingLoadedSignal()
		{
			super(GalleryImageProxy, BitmapData);
		}
	}
}
