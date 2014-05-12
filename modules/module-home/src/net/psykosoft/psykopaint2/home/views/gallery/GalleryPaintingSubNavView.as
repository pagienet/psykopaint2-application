package net.psykosoft.psykopaint2.home.views.gallery
{

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.sampler.StackFrame;
	import flash.text.TextField;

	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class GalleryPaintingSubNavView extends SubNavigationViewBase
	{
//		public static const ID_BACK : String = "Back";
		public static const ID_LOVE:String = "Love";
		public static const ID_COMMENT:String = "Comment";
		public static const ID_SHARE:String = "Share";
		public static const PROFILE:String = "profile";

		private var _userThumbnailURL:String;
		private var _userBitmapLoader:Loader;
		private var _userBitmap:Bitmap;
		private var _container:MovieClip;

		public function GalleryPaintingSubNavView()
		{
			super();
			_container = new PhotoFrameAsset();
			_container.scaleX = _container.scaleY = .5/* * CoreSettings.GLOBAL_SCALING */;
			_container.x = -_container.width / 2 + 2/* * CoreSettings.GLOBAL_SCALING */;
			_container.y = -_container.height / 2 + 4/* * CoreSettings.GLOBAL_SCALING */;
		}

		public function setUserProfile(name:String, url:String):void
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
			if (_userBitmapLoader)
				closeLoader();

			disposeUserBitmap();
			super.dispose();
		}

		private function loadThumbnail():void
		{
			disposeUserBitmap();

			if (_userBitmapLoader)
				closeLoader();

			_userBitmapLoader = new Loader();
			_userBitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_userBitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_userBitmapLoader.load(new URLRequest(_userThumbnailURL));
		}

		private function closeLoader():void
		{
			try {
				_userBitmapLoader.close();
			}
			catch (error:Error) {
				// Sadly, there doesn't seem to be a proper fix for this thrown error. When closing quickly after opening a stream, seems like a Flash-internal race condition.
				trace ("Caught closing error.");
			}
			removeLoadListeners();
			_userBitmapLoader = null;
		}

		private function onLoadError(event:IOErrorEvent):void
		{
			removeLoadListeners();
			_userBitmapLoader = null;
		}

		private function onLoadComplete(event:Event):void
		{
			removeLoadListeners();
			_userBitmap = Bitmap(_userBitmapLoader.content);
			_userBitmap.x = 3;
			_userBitmap.y = 7;
			_userBitmap.smoothing = true;
			_userBitmap.width = 168;
			_userBitmap.height = 168;
			_container.addChildAt(_userBitmap, 0);
			_userBitmapLoader = null;

		}

		private function removeLoadListeners():void
		{
			_userBitmapLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			_userBitmapLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}

		override protected function onEnabled():void
		{
			setHeader("");
//			setLeftButton(ID_BACK, ID_BACK);
		}

		override protected function onSetup():void
		{
			super.onSetup();
			createCenterButton(ID_LOVE, ID_LOVE, ButtonIconType.LOVE, IconButton, null, false, true, true, MouseEvent.MOUSE_UP);
			createCenterButton(ID_SHARE, ID_SHARE, ButtonIconType.SHARE);

			validateCenterButtons();

			getRightButton().addChild(_container);
		}

		public function setLoveCount(count:int):void
		{
			var btn:IconButton = IconButton(getItemRendererForElementWithId(ID_LOVE));
			var lbl:TextField = btn.icon.getChildByName("txt") as TextField;
			lbl.text = count.toString();
		}
	}
}
