package net.psykosoft.psykopaint2.home.views.picksurface
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;

	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreSurfaceSetSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestZoomThenChangeStateSignal;

	public class PickSurfaceSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickSurfaceSubNavView;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestDrawingCoreResetSignal:RequestDrawingCoreResetSignal;

		[Inject]
		public var requestZoomThenChangeStateSignal:RequestZoomThenChangeStateSignal;

		[Inject]
		public var requestDrawingCoreSurfaceSetSignal:RequestDrawingCoreSurfaceSetSignal;

		private var _bitmapLoader:BitmapLoader;
		private var _byteLoader:BinaryLoader;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;
			previewSurfaceByIndex( 0 );
			// TODO: must display thumbnails, assets are on /core-packaged/images/surfaces/ as jpgs
		}

		private function onButtonClicked( label:String ):void {

			switch( label ) {
				case PickSurfaceSubNavView.LBL_BACK:
					requestStateChange( StateType.PREVIOUS );
					break;
				case PickSurfaceSubNavView.LBL_CONTINUE:
					pickSurfaceByIndex( view.getSelectedCenterButtonIndex() );
					break;
				case PickSurfaceSubNavView.LBL_SURF1:
					previewSurfaceByIndex( 0 );
					break;
				case PickSurfaceSubNavView.LBL_SURF2:
					previewSurfaceByIndex( 1 );
					break;
				case PickSurfaceSubNavView.LBL_SURF3:
					previewSurfaceByIndex( 2 );
					break;
			}
		}

		private function pickSurfaceByIndex( index:int ):void {
			_byteLoader = new BinaryLoader();
			var size:int = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2048 : 1024;
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_" + size + ".surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			requestDrawingCoreSurfaceSetSignal.dispatch( bytes );
			requestStateChange( StateType.PICK_IMAGE );
			_byteLoader.dispose();
			_byteLoader = null;
		}

		private function previewSurfaceByIndex( index:uint ):void {
			_bitmapLoader = new BitmapLoader();
			var size:int = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2048 : 1024;
			_bitmapLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_" + size + "_sample.jpg", onSurfacePreviewLoaded );
		}

		private function onSurfacePreviewLoaded( bmd:BitmapData ):void {
			requestEaselPaintingUpdateSignal.dispatch( bmd );
			_bitmapLoader.dispose();
			_bitmapLoader = null;
		}
	}
}
