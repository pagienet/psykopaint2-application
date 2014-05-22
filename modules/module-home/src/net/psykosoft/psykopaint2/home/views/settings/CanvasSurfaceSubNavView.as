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

		private var _wood : Bitmap;
		private var _canvas : Bitmap;
		private var _loader : Loader;
		private var _selectedButtonID:String;

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
			if (_wood) {
				_wood.bitmapData.dispose();
				_wood = null;
			}
			if (_canvas) {
				_canvas.bitmapData.dispose();
				_canvas = null;
			}
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onWoodLoadComplete);
				try {
					_loader.close();
				}
				catch(error : Error) {
					// catch is nasty, but this error is SERIOUSLY irrelevant
				}
				_loader = null;
			}
		}

		override protected function onSetup():void
		{
			super.onSetup();
			loadIcon("/core-packaged/images/surfaces/canvas_normal_specular_0_icon.jpg", onCanvasLoadComplete);
		}

		private function loadIcon(filename:String, onComplete:Function):void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(filename));
		}

		private function onCanvasLoadComplete(event : Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCanvasLoadComplete);
			_canvas = Bitmap(_loader.content);
			loadIcon("/core-packaged/images/surfaces/canvas_normal_specular_1_icon.jpg", onWoodLoadComplete);
		}

		private function onWoodLoadComplete(event : Event):void
		{
			_wood = Bitmap(_loader.content);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onWoodLoadComplete);
			_loader = null;
			createCenterButton(ID_CANVAS, ID_CANVAS, null, PolaroidButton, _canvas, true);
			createCenterButton(ID_WOOD, ID_WOOD, null, PolaroidButton, _wood, true);
			validateCenterButtons();
			if (_selectedButtonID) selectButtonWithLabel(_selectedButtonID);
		}

		public function setSelectedButton(id : String) : void
		{
			_selectedButtonID = id;

			if (_wood || _canvas)
				selectButtonWithLabel(id);
		}
	}
}
