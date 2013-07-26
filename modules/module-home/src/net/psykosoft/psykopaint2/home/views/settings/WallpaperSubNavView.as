package net.psykosoft.psykopaint2.home.views.settings
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbPolaroidButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class WallpaperSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Settings";

		static private var _lastSelectedWallpaper:String = "default";

		private var _atlas:BitmapAtlas;

		public function WallpaperSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Settings" );
			setLeftButton( LBL_BACK, ButtonIconType.SETTINGS );
		}

		override protected function onDisposed():void {
			if( _atlas ) _atlas.dispose();
			_atlas = null;
		}

		public function setImages( atlas:BitmapAtlas ):void {
			_atlas = atlas;
			var names:Vector.<String> = atlas.names;
			for( var i:uint; i < names.length; i++ ) {
				var name:String = names[ i ];
				createCenterButton( name, null, SbPolaroidButton, new Bitmap( atlas.getSubTextureForId( name ) ) );
			}
			validateCenterButtons();
		}

		public function setSelectedWallpaperBtn():void {
			// TODO: complete navigation refactor
//			_group.setSelectedButtonByLabel( _lastSelectedWallpaper );
		}

		static public function setLastSelectedWallpaper( value:String ):void {
			if( _lastSelectedWallpaper == value ) return;
			_lastSelectedWallpaper = value;
		}
	}
}
