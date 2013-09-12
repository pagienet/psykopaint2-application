package net.psykosoft.psykopaint2.book.model
{
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class DummyGalleryImageProxy extends GalleryImageProxy
	{
		public function DummyGalleryImageProxy()
		{
		}

		override public function loadThumbnail(onComplete : Function, onError : Function) : void
		{
			var bitmapData : TrackedBitmapData = new TrackedBitmapData(400, 300, false, 0);
			bitmapData.perlinNoise(64, 64, 8, Math.random(), true, true);
			onComplete(bitmapData);
		}
	}
}
