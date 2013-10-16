package net.psykosoft.psykopaint2.home.views.home
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import flash.display.Loader;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.home.views.home.atelier.Atelier;

	public class RoomView extends Sprite
	{
		private var _atelier : Atelier;
		private var _loader : URLLoader;
		private var _stage3DProxy : Stage3DProxy;

		public function RoomView(atelier : Atelier, stage3DProxy : Stage3DProxy)
		{
			_stage3DProxy = stage3DProxy;
			_atelier = atelier;
		}

		public function changeWallpaper(url : String) : void
		{
			if (_loader)
				_loader.close();

			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.load(new URLRequest(url));
		}

		private function onLoadComplete(event : Event) : void
		{
			_loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			_atelier.setWallImage(ByteArray(_loader.data));
			_loader = null;
		}
	}
}
