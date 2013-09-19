package net.psykosoft.psykopaint2.home.views.settings
{

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.base.utils.io.AtlasLoader;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.model.WallpaperModel;

	public class WallpaperSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:WallpaperSubNavView;

		[Inject]
		public var wallpaperModel:WallpaperModel;

		private var _atlasLoader:AtlasLoader;

		override public function initialize():void {
			registerView( view );
			super.initialize();
		}

		override protected function onViewSetup():void {
			super.onViewSetup();
			setAvailableWallpapers();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				// Left.
				case WallpaperSubNavView.ID_BACK: {
					requestNavigationStateChange( NavigationStateType.SETTINGS );
					break;
				}

				// Center buttons are wallpaper thumbnails.
				default: {
					wallpaperModel.wallpaperId = id;
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
		}
	}
}
