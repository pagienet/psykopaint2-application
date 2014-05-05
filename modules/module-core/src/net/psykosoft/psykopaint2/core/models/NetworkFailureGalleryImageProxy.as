package net.psykosoft.psykopaint2.core.models
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class NetworkFailureGalleryImageProxy extends GalleryImageProxy
	{
		private var _onComplete:Function;
		public function NetworkFailureGalleryImageProxy()
		{
			id = 0;
			collectionType = GalleryType.NONE;
			userName = null;
		}

		override public function loadThumbnail(onComplete : Function, onError : Function, size : int = 1) : void
		{
			_onComplete = onComplete;
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest("home-packaged/images/gallery/connectionLost.png"));
		}

		private function onLoadComplete(event:Event):void
		{
			var loader : Loader = LoaderInfo(event.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			_onComplete(Bitmap(loader.content).bitmapData);
		}

		override public function clone():GalleryImageProxy
		{
			var clone : DummyGalleryImageProxy = new DummyGalleryImageProxy();
			copyTo(clone);
			return clone;
		}

	}
}
