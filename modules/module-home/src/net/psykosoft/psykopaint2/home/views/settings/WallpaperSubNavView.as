package net.psykosoft.psykopaint2.home.views.settings
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class WallpaperSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Settings";

		static private var _lastSelectedWallpaper:String = "default";

		private var _atlas:BitmapAtlas;
		private var _group:ButtonGroup;

		public function WallpaperSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Settings" );
			navigation.setLeftButton( LBL_BACK, ButtonIconType.SETTINGS );
			navigation.layout();
		}

		override protected function onDisabled():void {
			if( _atlas ) _atlas.dispose();
		}

		public function setImages( atlas:BitmapAtlas ):void {
			_atlas = atlas;
			_group = new ButtonGroup();
			var names:Vector.<String> = atlas.names;
			for( var i:uint; i < names.length; i++ ) {
				var name:String = names[ i ];
				var btn:SbButton = navigation.createButton( name, ButtonIconType.POLAROID, ButtonLabelType.NO_BACKGROUND, new Bitmap( atlas.getSubTextureForId( name ) ) );
				_group.addButton( btn );
			}
			navigation.addCenterButtonGroup( _group );
			navigation.layout();
		}

		public function setSelectedWallpaperBtn():void {
			_group.setSelectedButtonByLabel( _lastSelectedWallpaper );
		}

		static public function setLastSelectedWallpaper( value:String ):void {
			if( _lastSelectedWallpaper == value ) return;
			_lastSelectedWallpaper = value;
		}
	}
}
