package net.psykosoft.psykopaint2.home.views.settings
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.PolaroidButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class WallpaperSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Settings";

		private var _atlas:BitmapAtlas;

		public function WallpaperSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
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
				createCenterButton( name, name, null, PolaroidButton, new Bitmap( atlas.getSubTextureForId( name ) ), true );
			}

			validateCenterButtons();

			// TODO: this is a hard code, because the home view selects a wallpaper by default, and this assumes one as well.
			// The selection of the default wallpaper needs to be centralized.
			selectButtonWithLabel( "white" );
		}
	}
}
