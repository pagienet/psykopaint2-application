package net.psykosoft.psykopaint2.home.views.settings
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.PolaroidButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CanvasSurfaceSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		/* Settings */
		public static const ID_CANVAS:String = "Canvas";
		public static const ID_WOOD:String = "Wood";
		public static const ID_PAPER:String = "Paper";

		//private var _loader : Loader;
		private var _selectedButtonID:String;

		private var _surfaceIDS : Vector.<String> = Vector.<String>([ ID_CANVAS, ID_WOOD, ID_PAPER ]);
		private var _loadingIndex : int = 0;
		//private var _icons:Vector.<Bitmap>;

		public function CanvasSurfaceSubNavView()
		{
			super();
		}

		override protected function onEnabled():void
		{
			setHeader("");
			setLeftButton(ID_BACK, ID_BACK, ButtonIconType.BACK);
		}


		override public function dispose():void
		{
			super.dispose();
			/*for (var i : uint = 0; i < _icons.length; ++i) {
				if (_icons[i])
					_icons[i].bitmapData.dispose();
			}

			_icons = null;*/

			/*if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onIconLoadComplete);
				try {
					_loader.close();
				}
				catch(error : Error) {
					// catch is nasty, but this error is SERIOUSLY irrelevant
				}
				_loader = null;
			}*/
		}

		override protected function onSetup():void
		{
			super.onSetup();

			startLoadingIcons();
		}

		private function startLoadingIcons():void
		{
			//_loadingIndex = 0;
			//_icons = new Vector.<Bitmap>();
			//loadNextIcon();
			onIconsLoaded();
		}
		/*
		private function loadNextIcon():void
		{
			var filename : String = "/core-packaged/images/surfaces/canvas_normal_specular_" + _loadingIndex + "_icon.jpg";

			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onIconLoadComplete);
			_loader.load(new URLRequest(filename));
		}

		private function onIconLoadComplete(event : Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onIconLoadComplete);
			_icons[_loadingIndex] = Bitmap(_loader.content);

			if (++_loadingIndex == _surfaceIDS.length)
				onIconsLoaded();
			else
				loadNextIcon();
		}*/

		private function onIconsLoaded():void
		{
			//_loader = null;
			
			for (var i : int = 0; i < _surfaceIDS.length; ++i) {
				createCenterButton(_surfaceIDS[i], _surfaceIDS[i], _surfaceIDS[i], null, null, true);
			}

			validateCenterButtons();
			if (_selectedButtonID) selectButtonWithLabel(_selectedButtonID);
		}

		public function setSelectedButton(id : String) : void
		{
			_selectedButtonID = id;

			//if (areAllIconsLoaded())
				selectButtonWithLabel(id);
		}

		/*private function areAllIconsLoaded():Boolean
		{
			return _icons && _icons.length == _surfaceIDS.length;
		}*/
	}
}
