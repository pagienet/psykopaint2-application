package net.psykosoft.psykopaint2.home.views.picksurface
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PickSurfaceSubNavViewMediator extends MediatorBase
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

		private var _selectedIndex:int;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;
			view.showRightButton( false );
			requestEaselPaintingUpdateSignal.dispatch( null, false, false );
			_selectedIndex = -1;

			// From app.
			notifySurfacePreviewLoadedSignal.add( onSurfacePreviewLoaded );
			notifySurfaceLoadedSignal.add( onSurfaceLoaded );
		}

		private function onButtonClicked( label:String ):void {

			switch( label ) {
				case PickSurfaceSubNavView.LBL_BACK:
					requestStateChange( StateType.HOME_ON_EASEL );
					break;
				case PickSurfaceSubNavView.LBL_CONTINUE:
					if( _selectedIndex >= 0 ) requestLoadSurfaceSignal.dispatch( _selectedIndex );
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

		private function onSurfaceLoaded():void {
			requestStateChange( StateType.PREPARE_FOR_PAINT_MODE );
		}
	}
}
