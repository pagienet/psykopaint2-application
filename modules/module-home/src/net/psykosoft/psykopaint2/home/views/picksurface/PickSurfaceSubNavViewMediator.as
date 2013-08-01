package net.psykosoft.psykopaint2.home.views.picksurface
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;

	public class PickSurfaceSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:PickSurfaceSubNavView;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestLoadSurfacePreviewSignal:RequestLoadSurfacePreviewSignal;

		[Inject]
		public var notifySurfacePreviewLoadedSignal:NotifySurfacePreviewLoadedSignal;

		[Inject]
		public var requestLoadSurfaceSignal:RequestLoadSurfaceSignal;

		[Inject]
		public var notifySurfaceLoadedSignal:NotifySurfaceLoadedSignal;

		[Inject]
		public var requestOpenPaintingDataVOSignal : RequestOpenPaintingDataVOSignal;

		private var _selectedIndex:int;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			_selectedIndex = -1;

			// From app.
			notifySurfacePreviewLoadedSignal.add( onSurfacePreviewLoaded );
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.showRightButton( false );
			requestEaselPaintingUpdateSignal.dispatch( null, false, false );
		}

		override protected function onButtonClicked( label:String ):void {

			switch( label ) {
				case PickSurfaceSubNavView.LBL_BACK:
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.HOME_ON_EASEL );
					break;
				case PickSurfaceSubNavView.LBL_CONTINUE:
					continueToColorPaint();
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

		private function loadSurfaceByIndex( index:uint ):void {
			if( _selectedIndex == index ) return;
			view.showRightButton( false );
			requestLoadSurfacePreviewSignal.dispatch( index );
			_selectedIndex = index;
		}

		private function onSurfacePreviewLoaded():void {
			view.showRightButton( true );
		}

		private function continueToColorPaint():void {

			notifySurfaceLoadedSignal.addOnce( onSurfaceLoaded );
			// Request the load of the surface.
			requestLoadSurfaceSignal.dispatch( _selectedIndex );
		}

		private function onSurfaceLoaded(data : ByteArray):void {
			var vo : PaintingDataVO = new PaintingDataVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;
			vo.colorData = createBlankData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0xffffffff);
			vo.sourceBitmapData = createBlankData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, 0xffffffff);
			data.uncompress();
			vo.normalSpecularData = data;
			requestOpenPaintingDataVOSignal.dispatch(vo);
		}

		private function createBlankData(width : int, height : int, value : uint) : ByteArray
		{
			var len : int = width*height;
			var ba : ByteArray = new ByteArray();
			for (var i : int = 0; i < len; ++i)
				ba.writeUnsignedInt(value);
			ba.position = 0;
			return ba;
		}
	}
}
