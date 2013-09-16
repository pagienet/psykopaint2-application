package net.psykosoft.psykopaint2.book.model
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class DummyGalleryImageProxy extends GalleryImageProxy
	{
		public function DummyGalleryImageProxy()
		{
		}

		override public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			var width : int;
			var height : int;

			if (size == ImageThumbnailSize.SMALL) {
				width = 150;
				height = 100;
			}
			else if (size == ImageThumbnailSize.LARGE) {
				width = 300;
				height = 200;
			}
			else
				throw "Invalid size!";

			var bitmapData : TrackedBitmapData = new TrackedBitmapData(width, height, false, 0);
			bitmapData.perlinNoise(64, 64, 8, Math.random(), true, true);
			onComplete(bitmapData);
		}
	}
}
