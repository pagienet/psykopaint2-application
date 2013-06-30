package net.psykosoft.psykopaint2.home.views.picksurface
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestZoomThenChangeStateSignal;

	public class HomePickSurfaceSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomePickSurfaceSubNavView;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestDrawingCoreResetSignal:RequestDrawingCoreResetSignal;

		[Inject]
		public var requestZoomThenChangeStateSignal:RequestZoomThenChangeStateSignal;

		private var _loader:BitmapLoader;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
		}

		private function onButtonClicked( label:String ):void {

			switch( label ) {
				case HomePickSurfaceSubNavView.LBL_BACK:
//					requestStateChange( StateType.PREVIOUS );
					break;
				case HomePickSurfaceSubNavView.LBL_CONTINUE:
					// TODO: this is a temporary implementation, need to go through source image selection, cropping, etc
					requestDrawingCoreResetSignal.dispatch();
					requestZoomThenChangeStateSignal.dispatch( 1, StateType.PAINT );
					break;
				case HomePickSurfaceSubNavView.LBL_SURF1:
					pickSurfaceByIndex( 0 );
					break;
				case HomePickSurfaceSubNavView.LBL_SURF2:
					pickSurfaceByIndex( 1 );
					break;
				case HomePickSurfaceSubNavView.LBL_SURF3:
					pickSurfaceByIndex( 2 );
					break;
			}
		}

		private function pickSurfaceByIndex( index:uint ):void {
			_loader = new BitmapLoader();
			_loader.loadAsset( "/core-packaged/images/surfaces/canvas-height-specular" + index + "-sample.jpg", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bmd:BitmapData ):void {
			requestEaselPaintingUpdateSignal.dispatch( bmd );
			_loader.dispose();
			_loader = null;
		}
	}
}
