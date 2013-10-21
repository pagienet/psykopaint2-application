package net.psykosoft.psykopaint2.home.views.picksurface
{
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.home.commands.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestOpenPaintingDataVOSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestStartNewColorPaintingSignal;

	public class PickSurfaceSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:PickSurfaceSubNavView;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestLoadSurfacePreviewSignal:RequestLoadSurfacePreviewSignal;

		[Inject]
		public var requestStartColorPaintingSignal : RequestStartNewColorPaintingSignal;

		private var _selectedIndex:int;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			_selectedIndex = -1;
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			loadSurfaceByIndex( 0 );
		}

		override protected function onButtonClicked( id:String ):void {

			switch( id ) {
				case PickSurfaceSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.HOME_ON_EASEL );
					break;
				case PickSurfaceSubNavView.ID_SURF1:
					if( _selectedIndex != 0 ) loadSurfaceByIndex( 0 );
					else continueToColorPaint();
					break;
				case PickSurfaceSubNavView.ID_SURF2:
					if( _selectedIndex != 1 ) loadSurfaceByIndex( 1 );
					else continueToColorPaint();
					break;
				case PickSurfaceSubNavView.ID_SURF3:
					if( _selectedIndex != 2 ) loadSurfaceByIndex( 2 );
					else continueToColorPaint();
					break;
			}
		}

		private function loadSurfaceByIndex( index:uint ):void {
			if( _selectedIndex == index ) return;
			requestLoadSurfacePreviewSignal.dispatch( index );
			_selectedIndex = index;
		}

		private function continueToColorPaint():void {
			requestStartColorPaintingSignal.dispatch(_selectedIndex);
		}
	}
}
