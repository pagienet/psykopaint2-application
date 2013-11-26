package net.psykosoft.psykopaint2.home.views.gallery
{
	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.home.model.GalleryImageCache;

	import org.osflash.signals.Signal;

	public class GalleryView extends Sprite
	{
		public var requestImageCollection : Signal = new Signal(int, int, int); // source, start index, amount of images

		private var _imageCache : GalleryImageCache;

		public function GalleryView()
		{
			_imageCache = new GalleryImageCache();
		}

		public function setActiveImage(galleryImageProxy : GalleryImageProxy) : void
		{
			const amountOnEachSide : int = 5;
			var min : int = galleryImageProxy.index - amountOnEachSide;
			var amount : int = amountOnEachSide * 2 + 1;

			if (min < 0) {
				amount += min;	// fix amount to still have correct amount of the right
				min = 0;
			}

			requestImageCollection.dispatch(galleryImageProxy.collectionType, min, amount);
		}

		public function setImageCollection(collection : GalleryImageCollection) : void
		{
			_imageCache.replaceCollection(collection);
		}
	}
}
