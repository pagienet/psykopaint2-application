package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;

	import net.psykosoft.psykopaint2.base.utils.io.AtlasLoader;
	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;

	public class PickASampleImageSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickASampleImageSubNavView;

		[Inject]
		public var requestSourceImageSetSignal:RequestSourceImageSetSignal;

		private var _atlasLoader:AtlasLoader;
		private var _imageLoader:BitmapLoader; // Will load full size jpg files.

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;

			// Trigger thumbnail load.
			setAvailableSamples();
		}

		private function setAvailableSamples():void {
			_atlasLoader = new AtlasLoader();
			_atlasLoader.loadAsset( "/paint-packaged/samples/samples.png", "/paint-packaged/samples/samples.xml", onAtlasReady );
		}

		private function onAtlasReady( loader:AtlasLoader ):void {
			view.setImages( new BitmapAtlas( loader.bmd, loader.xml ) );
			_atlasLoader.dispose();
			_atlasLoader = null;
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case PickASampleImageSubNavView.LBL_BACK:
				{
					requestStateChange( StateType.PICK_IMAGE );
					break;
				}
				default:
				{ // Center buttons are sample thumbnails.
					getFullImageAndSetAsSample( label );
				}
			}
		}

		private function getFullImageAndSetAsSample( id:String ):void {
			if( _imageLoader ) {
				_imageLoader.dispose();
				_imageLoader = null;
			}
			_imageLoader = new BitmapLoader();
//			var rootUrl:String = CoreSettings.RUNNING_ON_iPAD ? "/paint-packaged-ios/" : "/paint-packaged-desktop/";
			var rootUrl:String = "/paint-packaged/";
//			var extra:String = CoreSettings.RUNNING_ON_iPAD ? "-ios" : "-desktop";
			var extra:String = "";
			_imageLoader.loadAsset( rootUrl + "samples/fullsize/" + id + extra + ".jpg", onImageLoaded );
		}

		private function onImageLoaded( bmd:BitmapData ):void {
			requestSourceImageSetSignal.dispatch( bmd );
			_imageLoader.dispose();
			_imageLoader = null;
		}
	}
}
