package net.psykosoft.psykopaint2.home.views.picksurface
{

	import flash.display.BitmapData;
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
		private var _selectedIndex : int = -1;
		private var _loadedSurface : ByteArray;

		override public function initialize():void {

			// Init.
			super.initialize();
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
					requestDrawingCoreSurfaceSetSignal.dispatch( _loadedSurface );
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
			if (_byteLoader) _byteLoader.dispose();
			_byteLoader = new BinaryLoader();
			var size:int = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2048 : 1024;
			_byteLoader.loadAsset( "/core-packaged/images/surfaces/canvas_normal_specular_" + index + "_" + size + ".surf", onSurfaceLoaded );
		}

		private function disposeSurface() : void
		{
			if (_loadedSurface) {
				_loadedSurface.clear();
				_loadedSurface = null;
			}
		}

		private function onSurfaceLoaded( bytes:ByteArray ):void {
			_loadedSurface = bytes;
			view.showRightButton( true );
			_byteLoader.dispose();
			_byteLoader = null;

			var vo : PaintingInfoVO = createPaintingVO();
			requestEaselPaintingUpdateSignal.dispatch( vo );
			vo.dispose();
		}

		private function createPaintingVO() : PaintingInfoVO
		{
			var vo : PaintingInfoVO = new PaintingInfoVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			vo.colorPreviewData = new ByteArray();
			vo.colorPreviewData.length = vo.width*vo.height*4;	// will fill with zeroes
			vo.normalSpecularPreviewData = new ByteArray();
			vo.normalSpecularPreviewData.writeBytes(_loadedSurface, 0, 0);
			vo.normalSpecularPreviewData.uncompress();
			// nothing else necessary
			return vo;
		}
	}
}
