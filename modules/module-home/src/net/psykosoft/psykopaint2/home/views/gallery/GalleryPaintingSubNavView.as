package net.psykosoft.psykopaint2.home.views.gallery
{

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class GalleryPaintingSubNavView extends SubNavigationViewBase
	{
//		public static const ID_BACK : String = "Back";
		public static const ID_LOVE : String = "Love";
		public static const ID_COMMENT : String = "Comment";
		public static const ID_SHARE : String = "Share";
		public static const PROFILE : String = "profile";

		private var _userThumbnailURL : String;
		private var _loader:Loader;
		private var _userBitmap:Bitmap;
		private var _container:MovieClip;

		public function GalleryPaintingSubNavView()
		{
			super();
			_container = new PhotoFrameAsset();
			_container.scaleX = _container.scaleY = .5 * CoreSettings.GLOBAL_SCALING;
			_container.x = -_container.width/2 + 2 * CoreSettings.GLOBAL_SCALING;
			_container.y = -_container.height/2 + 4 * CoreSettings.GLOBAL_SCALING;
		}

		public function setUserProfile(name : String, url : String) : void
		{
			setRightButton(PROFILE, name, ButtonIconType.EMPTY, true);

			if (_userThumbnailURL != url) {
				_userThumbnailURL = url;
				loadThumbnail();
			}
		}

		private function disposeUserBitmap():void
		{
			if (_userBitmap) {
				_container.removeChild(_userBitmap);
				_userBitmap.bitmapData.dispose();
				_userBitmap = null;
			}
		}

		override public function dispose():void
		{
			getRightButton().removeChild(_container);
			if (_loader) {
				_loader.close();
				removeLoadListeners();
			}
			disposeUserBitmap();
			super.dispose();
		}

		private function loadThumbnail():void
		{
			disposeUserBitmap();
			if (_loader) _loader.close();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_loader.load(new URLRequest(_userThumbnailURL));
		}

		private function onLoadError(event:IOErrorEvent):void
		{
			removeLoadListeners();
			_loader = null;
		}

		private function onLoadComplete(event:Event):void
		{
			removeLoadListeners();
			_userBitmap = Bitmap(_loader.content);
			_userBitmap.x = 3;
			_userBitmap.y = 7;
			_userBitmap.smoothing = true;
			_userBitmap.width = 168;
			_userBitmap.height = 168;
			_container.addChildAt(_userBitmap, 0);
			_loader = null;

		}

		private function removeLoadListeners():void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}

		override protected function onEnabled() : void
		{
			setHeader("");
//			setLeftButton(ID_BACK, ID_BACK);
		}

		override protected function onSetup() : void
		{
			super.onSetup();
			var loveButon:ButtonData = createCenterButton(ID_LOVE, ID_LOVE, ButtonIconType.LOVE);
			
			//TextField(loveButon['txt']).text=String(Math.round(Math.random()*100));
			//createCenterButton(ID_COMMENT, ID_COMMENT, ButtonIconType.COMMENT);
			createCenterButton(ID_SHARE, ID_SHARE, ButtonIconType.SHARE);
			
			validateCenterButtons();

			getRightButton().addChild(_container);
		}
	}
}
