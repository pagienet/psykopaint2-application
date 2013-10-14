package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.base.utils.data.ByteArrayUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.SurfaceDataVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselTappedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;
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

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var notifyEaselTappedSignal:NotifyEaselTappedSignal;

		private var _selectedIndex:int;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			_selectedIndex = -1;

			// From app.
			notifySurfacePreviewLoadedSignal.add( onSurfacePreviewLoaded );
		}

		override public function destroy():void {
			notifySurfacePreviewLoadedSignal.remove( onSurfacePreviewLoaded );
			super.destroy();
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.showRightButton( false );
			requestEaselPaintingUpdateSignal.dispatch( null, false, false );
			notifyEaselTappedSignal.add( onEaselTapped );
		}

		override protected function onViewDisabled():void {
			super.onViewDisabled();
			notifyEaselTappedSignal.remove( onEaselTapped );
		}

		override protected function onButtonClicked( id:String ):void {

			switch( id ) {
				case PickSurfaceSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.HOME_ON_EASEL );
					requestHomePanningToggleSignal.dispatch( 1 );
					break;
				case PickSurfaceSubNavView.ID_SURF1:
					loadSurfaceByIndex( 0 );
					break;
				case PickSurfaceSubNavView.ID_SURF2:
					loadSurfaceByIndex( 1 );
					break;
				case PickSurfaceSubNavView.ID_SURF3:
					loadSurfaceByIndex( 2 );
					break;
			}
		}

		private function onEaselTapped():void {
			continueToColorPaint();
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
			requestLoadSurfaceSignal.dispatch( _selectedIndex );
		}

		private function onSurfaceLoaded(surface : SurfaceDataVO):void {
			var vo : PaintingDataVO = new PaintingDataVO();
			vo.width = CoreSettings.STAGE_WIDTH;
			vo.height = CoreSettings.STAGE_HEIGHT;

			if (surface.color) {
				vo.colorData = surface.color;
				vo.colorBackgroundOriginal = surface.color;
			}
			else
				vo.colorData = ByteArrayUtil.createBlankColorData(vo.width, vo.height, 0xffffffff);

			vo.normalSpecularData = surface.normalSpecular;
			vo.normalSpecularOriginal = surface.normalSpecular;

			requestOpenPaintingDataVOSignal.dispatch(vo);
		}
	}
}
