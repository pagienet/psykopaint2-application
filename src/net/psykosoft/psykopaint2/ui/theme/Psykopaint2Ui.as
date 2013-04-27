package net.psykosoft.psykopaint2.ui.theme
{

	import feathers.themes.MinimalMobileTheme;
	
	import net.psykosoft.psykopaint2.ui.theme.buttons.LabelButtonSkinManager;
	import net.psykosoft.psykopaint2.ui.theme.buttons.LeftEdgeLabelButtonSkinManager;
	import net.psykosoft.psykopaint2.ui.theme.buttons.PaperButtonSkinManager;
	import net.psykosoft.psykopaint2.ui.theme.buttons.RightEdgeLabelButtonSkinManager;
	
	import starling.display.DisplayObjectContainer;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/*
	 // TODO:
	 << Important Note >>
	 For now, this theme will extend the MinimalMobileTheme so that we have backup graphics to fall to in case the main theme cannot provide skins for certain components.
	 Further along the line, while this theme becomes populated, the idea is to remove the MinimalMobileTheme extension and instead extend DisplayListWatcher, moving
	 all skinning functions to this theme. At such point, the theme will only contain skins for the components that are actually used in the app. For example, if in the end,
	 the app does not use a ScreenNavigator, there is no point in providing a skin for it.
	 When this happens, MinimalMobileTheme should be removed from the code base as well as its assets in assets/base.
	 */
	public class Psykopaint2Ui extends MinimalMobileTheme
	{
		private static var _instance:Psykopaint2Ui;

		private var _footerAtlas:TextureAtlas;
		private var _uiComponentsAtlas:TextureAtlas;
		private var _fontDescriptor:XML;
		private var _ext:String;
		
		
		
		public function Psykopaint2Ui( root:DisplayObjectContainer, themeFontDescriptor:XML, resolutionExtension:String,footerAtlas:TextureAtlas,uiComponentsAtlas:TextureAtlas ) {
			_footerAtlas= footerAtlas;
			_uiComponentsAtlas = uiComponentsAtlas;
			_instance = this;
			_ext = resolutionExtension;
			_fontDescriptor = themeFontDescriptor;
			super( root );
		}

		
		override protected function initialize():void {
			
			trace("Psykopaint2UI::initialize");
			
			super.initialize();

			// Buttons.
			new PaperButtonSkinManager();
			new LabelButtonSkinManager();
			new LeftEdgeLabelButtonSkinManager();
			new RightEdgeLabelButtonSkinManager();
		}

		// --------------------------
		// External texture request.
		// --------------------------

		public static const TEXTURE_NAVIGATION_BG:String = "bg";
		public static const TEXTURE_NAVIGATION_LEFT_CORNER:String = "leftCorner";
		public static const TEXTURE_NAVIGATION_RIGHT_CORNER:String = "rightCorner";
		public static const TEXTURE_NAVIGATION_ARROW:String = "leftArrow";
		public static const TEXTURE_NAVIGATION_CLAMP:String = "clamp";

		public function getTexture( id:String ):Texture {
			return _footerAtlas.getTexture( id  );
		}

		public static function get instance():Psykopaint2Ui {
			return _instance;
		}

		public function get ext():String {
			return _ext;
		}

		
		public function get footerAtlas():TextureAtlas {
			return _footerAtlas;
		}
		
		public function get uiComponentsAtlas():TextureAtlas
		{
			return _uiComponentsAtlas;
		}
		
	


		public function get fontDescriptor():XML {
			return _fontDescriptor;
		}
	}
}
