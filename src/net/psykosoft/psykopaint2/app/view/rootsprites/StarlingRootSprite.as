package net.psykosoft.psykopaint2.app.view.rootsprites
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.view.base.*;

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.core.DisplayListWatcher;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.navigation.NavigationView;
	import net.psykosoft.psykopaint2.app.view.painting.canvas.CanvasView;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleView;
	import net.psykosoft.psykopaint2.app.view.painting.crop.CropView;
	import net.psykosoft.psykopaint2.app.view.painting.stateproxy.StateProxyView;
	import net.psykosoft.psykopaint2.app.view.popups.base.PopUpManagerView;
	import net.psykosoft.psykopaint2.app.view.selectimage.SelectImageView;
	import net.psykosoft.psykopaint2.app.view.splash.SplashView;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.utils.loaders.AtlasLoader;
	import net.psykosoft.utils.loaders.XMLLoader;

	import starling.core.Starling;

	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class StarlingRootSprite extends StarlingViewBase
	{
		private var _mainLayer:Sprite;
		private var _debugLayer:Sprite;
		private var _themeAtlasLoader:AtlasLoader;
		private var _themeAtlasImage:BitmapData;
		private var _themeFontLoader:XMLLoader;
		private var _themeAtlasDescriptor:XML;
		private var _resolutionExtension:String;
		private var _themeFontDescriptor:XML;

		public function StarlingRootSprite() {
			super();
			enable();
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onCreate():void {
			loadThemeAtlas();
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function loadThemeAtlas():void {
			_themeAtlasLoader = new AtlasLoader();
			_resolutionExtension = Settings.RUNNING_ON_HD ? "-hr" : "-lr";
			_themeAtlasLoader.loadAsset( "/assets-packaged/theme/psykopaint2" + _resolutionExtension + ".png", "/assets-packaged/theme/psykopaint2" + _resolutionExtension + ".xml", onThemeAtlasLoaded );
		}

		private function onThemeAtlasLoaded( image:BitmapData, descriptor:XML ):void {
			_themeAtlasImage = image;
			_themeAtlasDescriptor = descriptor;
			_themeAtlasLoader.dispose();
			_themeAtlasLoader = null;
			loadThemeFont();
		}

		private function loadThemeFont():void {
			_themeFontLoader = new XMLLoader();
			_themeFontLoader.loadAsset( "/assets-packaged/theme/helveticaneue.fnt", onThemeFontLoaded );
		}

		private function onThemeFontLoaded( xml:XML ):void {
			_themeFontDescriptor = xml;
			_themeFontLoader.dispose();
			_themeFontLoader = null;
			initializeDisplayTree();
		}

		private function initializeDisplayTree():void {

			// -----------------------
			// Ui theme.
			// -----------------------

			trace( this, "initializing display tree with Starling.contentScaleFactor: " + Starling.contentScaleFactor );
			var texture:Texture = Texture.fromBitmapData( _themeAtlasImage, false, false, Starling.contentScaleFactor );
			var themeAtlas:TextureAtlas = new TextureAtlas( texture, _themeAtlasDescriptor );
			_themeAtlasImage.dispose();
			_themeAtlasImage = null;
			new Psykopaint2Ui( stage, themeAtlas, _themeFontDescriptor, _resolutionExtension );

			// -----------------------
			// Layering.
			// -----------------------

			addChild( _mainLayer = new Sprite() );
			if( Settings.ENABLE_DEBUG_CONSOLE ) {
				addChild( _debugLayer = new Sprite() );
			}

			// -----------------------
			// << VIEWS >>.
			// -----------------------

			_mainLayer.addChild( new StateProxyView() );
			_mainLayer.addChild( new CanvasView() );
			_mainLayer.addChild( new CropView() );
			_mainLayer.addChild( new ColorStyleView() );
			_mainLayer.addChild( new SelectImageView() );
			_mainLayer.addChild( new NavigationView() );
			_mainLayer.addChild( new PopUpManagerView() );
			if( Settings.SHOW_SPLASH_SCREEN ) {
				_mainLayer.addChild( new SplashView() );
			}

			// -----------------------
			// Debugging console.
			// -----------------------

			if( Settings.ENABLE_DEBUG_CONSOLE ) {
			    // Place a little button at the left corner of the app for toggling the console.
				var button:Button = new Button();
				button.label = "console";
				button.x = Settings.SHOW_STATS ? 50 : 0;
				button.addEventListener( Event.TRIGGERED, onConsoleButtonTriggered );
				_debugLayer.addChild( button );
			}
		}

		private function onConsoleButtonTriggered( event:Event ):void {
			Cc.visible = !Cc.visible;
		}

	}
}