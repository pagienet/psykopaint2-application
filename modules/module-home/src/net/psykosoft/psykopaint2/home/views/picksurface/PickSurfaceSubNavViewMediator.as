package net.psykosoft.psykopaint2.home.views.picksurface
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfacePreviewLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestBlankSourceImageActivationSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfacePreviewSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

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
		public var requestBlankSourceImageActivationSignal:RequestBlankSourceImageActivationSignal;

		private var _selectedIndex:int;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
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

		private var _waitingForSurface:Boolean;
		private function continueToColorPaint():void {

			// Request the load of the surface.
			requestLoadSurfaceSignal.dispatch( _selectedIndex );
			_waitingForSurface = true;

			// Set a blank source image.
			// TODO: it would be nice to tell the drawing core to not use a source image altogether.
			var dummyBmd:BitmapData = new BitmapData( 1024 * CoreSettings.GLOBAL_SCALING, 768 * CoreSettings.GLOBAL_SCALING, false, 0 );
			requestBlankSourceImageActivationSignal.dispatch( dummyBmd );
		}

		private function onSurfaceLoaded():void {
			if( _waitingForSurface ) {
				requestStateChange( StateType.PREPARE_FOR_PAINT_MODE );
				_waitingForSurface = false;
			}
		}
	}
}
