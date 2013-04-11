package net.psykosoft.psykopaint2.app.view.rootsprites
{

	import com.junkbyte.console.Cc;
	
	import flash.display.BitmapData;
	
	import feathers.controls.Button;
	
	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
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
		private var _atlasLoader:AtlasLoader;
		private var _footerAtlas:TextureAtlas;
		private var _uiComponentsAtlas:TextureAtlas;
		private var _fontDescriptor:XML;

		public function get resolutionExtension ():String{
			return   Settings.RUNNING_ON_HD ? "-hd" : "-sd";
		}

		
		public function StarlingRootSprite() {
			super(); 
			enable();
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onCreate():void {
			_atlasLoader = new AtlasLoader();
			loadFooterAtlas();
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function loadFooterAtlas():void {
			_atlasLoader.loadAsset( "/assets-packaged/interface/footer/footer" + resolutionExtension + ".png", "/assets-packaged/interface/footer/footer" + resolutionExtension + ".xml", onFooterAtlasLoaded );
		}

		private function onFooterAtlasLoaded( image:BitmapData, descriptor:XML ):void {
			var texture:Texture = Texture.fromBitmapData( image, false, false, Starling.contentScaleFactor );
			_footerAtlas = new TextureAtlas( texture, descriptor );
			
			trace("footer atlas = "+_footerAtlas);
			
			image.dispose();
			image = null;
			
			loadUiComponentsAtlas();
		}
		
		private function loadUiComponentsAtlas():void {
			
			_atlasLoader.loadAsset( "/assets-packaged/interface/uicomponents/uicomponents" + resolutionExtension + ".png", "/assets-packaged/interface/uicomponents/uicomponents" + resolutionExtension + ".xml", onUIComponentsAtlasLoaded );
		}
		
		private function onUIComponentsAtlasLoaded( image:BitmapData, descriptor:XML ):void {
			var texture:Texture = Texture.fromBitmapData( image, false, false, Starling.contentScaleFactor );
			_uiComponentsAtlas = new TextureAtlas( texture, descriptor );
			
			trace("_uiComponentsAtlas atlas = "+_uiComponentsAtlas);
			
			//DISPOSE OF THE LOADER
			_atlasLoader.dispose();
			_atlasLoader = null;
			
			image.dispose();
			image = null;
			
			//LOAD FONT
			loadThemeFont();
			
		}		

		private function loadThemeFont():void {
			var fontLoader:XMLLoader = new XMLLoader();
			fontLoader.loadAsset( "/assets-packaged/interface/fonts/helveticaneue.fnt", function(xml:XML ):void{
				
				_fontDescriptor = xml;
				
				fontLoader.dispose();
				fontLoader = null;
				
				initializeDisplayTree();
			} );
		}


		private function initializeDisplayTree():void {

			// -----------------------
			// Ui theme.
			// -----------------------

			trace( this, "initializing display tree with Starling.contentScaleFactor: " + Starling.contentScaleFactor );
						
			trace("_uiComponentsAtlas atlas = "+_uiComponentsAtlas);
			trace("footerAtlas atlas = "+_footerAtlas);
			
			var psykopaint2UI:Psykopaint2Ui = new Psykopaint2Ui( stage, _fontDescriptor, resolutionExtension,_footerAtlas,_uiComponentsAtlas );

			
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