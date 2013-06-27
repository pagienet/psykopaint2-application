package net.psykosoft.psykopaint2.home.views.picksurface
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.utils.io.BinaryLoader;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class HomePickSurfaceSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomePickSurfaceSubNavView;

		private var _loader:BinaryLoader;

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
			_loader = new BinaryLoader();
			_loader.loadAsset( "/paint-packaged/surfaces/canvas-height-specular" + index + ".atf", onSurfaceLoaded );
		}

		private function onSurfaceLoaded( byteArray:ByteArray ):void {
//			requestSurfaceImageSetSignal.dispatch( byteArray );
			// TODO: order easel to change
			_loader.dispose();
			_loader = null;
		}
	}
}
