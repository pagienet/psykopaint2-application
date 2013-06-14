package net.psykosoft.psykopaint2.home.views.settings
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.AtlasLoader;
	import net.psykosoft.psykopaint2.base.utils.BinaryLoader;
	import net.psykosoft.psykopaint2.base.utils.BitmapAtlas;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestWallpaperChangeSignal;

	public class WallpaperSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:WallpaperSubNavView;

		[Inject]
		public var requestWallpaperChangeSignal:RequestWallpaperChangeSignal;

		private var _atlasLoader:AtlasLoader;
		private var _imageLoader:BinaryLoader; // Will load full size atf files.

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// Trigger thumbnail load.
			setAvailableWallpapers();
		}

		private function setAvailableWallpapers():void {
			_atlasLoader = new AtlasLoader();
			_atlasLoader.loadAsset( "/home-packaged/away3d/wallpapers/wallpapers.png", "/home-packaged/away3d/wallpapers/wallpapers.xml", onAtlasReady );
		}

		private function onAtlasReady( bmd:BitmapData, xml:XML ):void {
			view.setImages( new BitmapAtlas( bmd, xml ) );
			_atlasLoader.dispose();
			_atlasLoader = null;
			view.setSelectedWallpaperBtn();
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case WallpaperSubNavView.LBL_BACK: {
					requestStateChange( StateType.SETTINGS );
					break;
				}
				default: { // Center buttons are wallpaper thumbnails.
					getFullImageAndSetAsWallpaper( label );
					WallpaperCache.setLastSelectedWallpaper( label );
				}
			}
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
