package net.psykosoft.psykopaint2.home.signals
{

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;

	import org.osflash.signals.Signal;

	public class RequestSetGalleryPaintingSignal extends Signal
	{
		public function RequestSetGalleryPaintingSignal() {
			// The GalleryImageProxy containing the painting info and provides access to the image's resources
			super(GalleryImageProxy);
		}
	}
}
