package net.psykosoft.psykopaint2.home.views.picksurface
{

	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;

	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoFactory;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
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

		private var _byteLoader:BinaryLoader;
		private var _bitmapLoader : BitmapLoader;
		private var _selectedIndex : int = -1;
		private var _loadedNormalSpecularData : ByteArray;
		private var _loadedColorData : BitmapData;
		private var _assetSize : int;

		override public function initialize():void {

			// Init.
			super.initialize();
			_assetSize = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2048 : 1024;
			registerView( view );
			_selectedIndex = -1;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;
			loadSurfaceByIndex( 0 );
			view.showRightButton( false );
			// TODO: must display thumbnails, assets are on /core-packaged/images/surfaces/ as jpgs
		}

		private function onButtonClicked( label:String ):void {

			switch( label ) {
				case PickSurfaceSubNavView.LBL_BACK:
					requestStateChange( StateType.PREVIOUS );
					break;
				case PickSurfaceSubNavView.LBL_CONTINUE:
					requestDrawingCoreSurfaceSetSignal.dispatch( _loadedNormalSpecularData, _loadedColorData );
					requestStateChange( StateType.PICK_IMAGE );
					break;
				case PickSurfaceSubNavView.LBL_SURF1:
					loadSurfaceByIndex( 0 );
					break;
				case PickSurfaceSubNavView.LBL_SURF2:
					loadSurfaceByIndex( 1 );
					break;
				case PickSurfaceSubNavView.LBL_SURF3:
					loadSurfaceByIndex( 2 );
					break;
			}
		}

		private function loadSurfaceByIndex( index:int ):void {
			if (_selectedIndex == index) return;
			disposeSurface();
			view.showRightButton( false );
			_selectedIndex = index;
			// cancel previous load
			if (_byteLoader) {
				_byteLoader.dispose();
				_byteLoader = null;
			}
			if (_bitmapLoader) {
				_bitmapLoader.dispose();
				_bitmapLoader = null;
			}
			loadColorData();
		}

		private function loadColorData() : void
		{
			_bitmapLoader = new BitmapLoader();
			_bitmapLoader.loadAsset( "/core-packaged/images/surfaces/canvas_color_" + _selectedIndex + "_" + _assetSize + ".jpg",
				onColorDataLoaded,
				onColorDataError);
		}

		private function onColorDataError() : void
		{
			_bitmapLoader.dispose();
			_bitmapLoader = null;
			trace ("Error loading '/core-packaged/images/surfaces/canvas_color_" + _selectedIndex + "_" + _assetSize + ".surf'")
			loadNormalSpecularData();
		}

		private function onColorDataLoaded(bitmap : BitmapData) : void
		{
			_loadedColorData = bitmap;
			_bitmapLoader.dispose();
			_bitmapLoader = null;
			loadNormalSpecularData();
		}

		private function loadNormalSpecularData() : void
		{
			_byteLoader = new BinaryLoader();
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + _selectedIndex + "_" + _assetSize + ".surf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			_loadedNormalSpecularData = bytes;
			view.showRightButton( true );
			_byteLoader.dispose();
			_byteLoader = null;

			var vo : PaintingInfoVO = createPaintingVO();
			requestEaselPaintingUpdateSignal.dispatch( vo );
			vo.dispose();
		}

		private function disposeSurface() : void
		{
			if (_loadedColorData) {
				_loadedColorData.dispose();
				_loadedColorData = null;
			}
			if (_loadedNormalSpecularData) {
				_loadedNormalSpecularData.clear();
				_loadedNormalSpecularData = null;
			}
		}

		private function createPaintingVO() : PaintingInfoVO
		{
			var vo : PaintingInfoVO = new PaintingInfoVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			if (_loadedColorData) {
				vo.colorPreviewBitmap = new BitmapData(vo.textureWidth, vo.textureHeight, false, 0);
				vo.colorPreviewBitmap.draw(_loadedColorData);
			}
			else {
				vo.colorPreviewData = new ByteArray();
				vo.colorPreviewData.length = vo.width*vo.height*4;	// will fill with zeroes
			}
			vo.normalSpecularPreviewData = new ByteArray();
			vo.normalSpecularPreviewData.writeBytes(_loadedNormalSpecularData, 0, 0);
			vo.normalSpecularPreviewData.uncompress();
			// nothing else necessary
			return vo;
		}
	}
}
