package net.psykosoft.psykopaint2.app.view.settings
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyWallpaperChangeSignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyWallpaperImagesUpdatedSignal;
	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.utils.loaders.AtlasLoader;
	import net.psykosoft.utils.loaders.BitmapLoader;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class SelectWallpaperSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SelectWallpaperSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		[Inject]
		public var notifyWallpaperImagesUpdatedSignal:NotifyWallpaperImagesUpdatedSignal;

		[Inject]
		public var notifyWallpaperChangeSignal:NotifyWallpaperChangeSignal;

		private var _atlasLoader:AtlasLoader;
		private var _imageLoader:BitmapLoader;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// Init ( fetch packaged wallpapers ).
			_atlasLoader = new AtlasLoader();
			_atlasLoader.loadAsset( "/assets-packaged/away3d/wallpapers/wallpapers.png", "/assets-packaged/away3d/wallpapers/wallpapers.xml", onAtlasReady );

			// From app.
//			notifyWallpaperImagesUpdatedSignal.add( onWallpaperImagesUpdated );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		private function onAtlasReady( bmd:BitmapData, xml:XML ):void {
			view.setImages( bmd, new TextureAtlas( Texture.fromBitmapData( bmd, false ), xml ) );
			_atlasLoader.dispose();
			_atlasLoader = null;
		}

		private function loadImage( url:String ):void {
			if( _imageLoader ) {
				_imageLoader.dispose();
				_imageLoader = null;
			}
			_imageLoader = new BitmapLoader();
			_imageLoader.loadAsset( url, onImageLoaded );
		}

		private function onImageLoaded( bmd:BitmapData ):void {
			_imageLoader.dispose();
			_imageLoader = null;
			notifyWallpaperChangeSignal.dispatch( bmd );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case SelectWallpaperSubNavigationView.BUTTON_LABEL_BACK:
					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) );
					break;

				default:

					trace( this, "requesting wallpaper change - id: " + buttonLabel );
					loadImage( "/assets-packaged/away3d/wallpapers/fullsize/" + buttonLabel + ".jpg" );

					break;
			}
		}
	}
}
