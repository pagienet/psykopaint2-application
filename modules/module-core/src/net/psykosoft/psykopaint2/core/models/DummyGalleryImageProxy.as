package net.psykosoft.psykopaint2.core.models
{
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

			if (size == ImageThumbnailSize.TINY) {
				width = 128;
				height =int( width*3/4);
			}
			else if (size == ImageThumbnailSize.SMALL) {
				width = 256;
				height = int( width*3/4);
			}
			else
				throw "Invalid size!";

			var bitmapData : TrackedBitmapData = new TrackedBitmapData(width, height, false, 0);
			bitmapData.perlinNoise(64, 64, 8, Math.random(), true, true);
			onComplete(bitmapData);
		}

		override public function loadFullSizedComposite(onComplete : Function, onError : Function) : void
		{
			var bitmapData : TrackedBitmapData = new TrackedBitmapData(1024, 768, false, 0);
			bitmapData.perlinNoise(512, 512, 8, Math.random(), true, true);
			onComplete(bitmapData);
		}

		override public function clone():GalleryImageProxy
		{
			var clone : DummyGalleryImageProxy = new DummyGalleryImageProxy();
			copyTo(clone);
			return clone;
		}

	}
}
