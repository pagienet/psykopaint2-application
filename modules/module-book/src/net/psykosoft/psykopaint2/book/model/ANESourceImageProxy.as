package net.psykosoft.psykopaint2.book.model
{
	import flash.display.BitmapData;

	import net.psykosoft.photos.UserPhotosExtension;

	public class ANESourceImageProxy implements SourceImageProxy
	{
		public var id : int;

		private var _ane : UserPhotosExtension;

		public function ANESourceImageProxy(ane : UserPhotosExtension)
		{
			_ane = ane;
		}

		public function loadThumbnail(onComplete : Function, onError : Function) : void
		{
			onComplete(_ane.getThumbnailAtIndex(id));
		}

		public function loadFullSized(onComplete : Function, onError : Function) : void
		{
			onComplete(_ane.getFullImageAtIndex(id));
		}
	}
}
