package net.psykosoft.psykopaint2.paint.views.pick.surface
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.io.BitmapLoader;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestSurfaceImageSetSignal;
import net.psykosoft.psykopaint2.paint.views.pick.surface.PickASurfaceCache;

public class PickASurfaceSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickASurfaceSubNavView;

		[Inject]
		public var requestSurfaceImageSetSignal:RequestSurfaceImageSetSignal;

		private var _loader:BitmapLoader;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
			view.setSelectedSurfaceBtn();
		}

		private function onButtonClicked( label:String ):void {

			switch( label ) {
				case PickASurfaceSubNavView.LBL_BACK:
					requestStateChange( StateType.PREVIOUS );
					break;
				case PickASurfaceSubNavView.LBL_SURF1:
						PickASurfaceCache.setLastSelectedSurface( label );
						pickSurfaceByIndex( 0 );
					break;
				case PickASurfaceSubNavView.LBL_SURF2:
						PickASurfaceCache.setLastSelectedSurface( label );
						pickSurfaceByIndex( 1 );
					break;
				case PickASurfaceSubNavView.LBL_SURF3:
						PickASurfaceCache.setLastSelectedSurface( label );
						pickSurfaceByIndex( 2 );
					break;
			}
		}

		private function pickSurfaceByIndex( index:uint ):void {
			_loader = new BitmapLoader();
			_loader.loadAsset( "/paint-packaged/surfaces/canvas-height-specular" + index + ".png", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( bmd:BitmapData ):void {
			requestSurfaceImageSetSignal.dispatch( bmd );
			_loader.dispose();
			_loader = null;
		}
	}
}
