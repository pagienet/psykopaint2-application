package net.psykosoft.psykopaint2.home.views.settings
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.base.utils.io.AtlasLoader;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	public class WallpaperSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:WallpaperSubNavView;

		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		private var _atlasLoader:AtlasLoader;
		private var _imageLoader:BinaryLoader; // Will load full size atf files.

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Trigger thumbnail load.
			setAvailableWallpapers();
		}

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {
				case WallpaperSubNavView.LBL_BACK: {
					requestStateChange( StateType.SETTINGS );
					break;
				}
				default: { // Center buttons are wallpaper thumbnails.
					getFullImageAndSetAsWallpaper( label );
					WallpaperSubNavView.setLastSelectedWallpaper( label );
				}
			}
		}

		private function setAvailableWallpapers():void {
			_atlasLoader = new AtlasLoader();
			_atlasLoader.loadAsset( "/home-packaged/away3d/wallpapers/wallpapers.png", "/home-packaged/away3d/wallpapers/wallpapers.xml", onAtlasReady );
		}

		private function onAtlasReady( loader:AtlasLoader ):void {
			view.setImages( new BitmapAtlas( loader.bmd, loader.xml ) );
			_atlasLoader.dispose();
			_atlasLoader = null;
			view.setSelectedWallpaperBtn();
		}

		private function getFullImageAndSetAsWallpaper( id:String ):void {
			if( _imageLoader ) {
				_imageLoader.dispose();
				_imageLoader = null;
			}
			_imageLoader = new BinaryLoader();
			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/home-packaged-ios/" : "/home-packaged-desktop/";
			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";
			_imageLoader.loadAsset( rootUrl + "away3d/wallpapers/fullsize/" + id + extra + ".atf", onImageLoaded );
		}

		private function onImageLoaded( atf:ByteArray ):void {
			requestWallpaperChangeSignal.dispatch( atf );
			_imageLoader.dispose();
			_imageLoader = null;
		}
	}
}
