package net.psykosoft.psykopaint2.home.views.settings
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class WallpaperSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Settings";

		private var _atlas:BitmapAtlas;

		public function WallpaperSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Settings" );

			navigation.setLeftButton( LBL_BACK );
			navigation.layout();
		}

		override protected function onDisabled():void {
			if( _atlas ) _atlas.dispose();
		}

		public function setImages( atlas:BitmapAtlas ):void {
			_atlas = atlas;
			var names:Vector.<String> = atlas.names;
			for( var i:uint; i < names.length; i++ ) {
				var name:String = names[ i ];
				navigation.addCenterButton( name, "", ButtonLabelType.CENTER, new Bitmap( atlas.getSubTextureForId( name ) ) );
			}
			navigation.layout();
		}

		public function setSelectedWallpaperBtn( ):void {
			selectButtonWithLabel( WallpaperCache.getLastSelectedWallpaper() );
		}
	}
}
