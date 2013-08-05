package net.psykosoft.psykopaint2.home.views.newpainting
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.models.PaintModeType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataSignal;

	public class NewPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:NewPaintingSubNavView;

		[Inject]
		public var requestLoadPaintingDataSignal:RequestLoadPaintingDataSignal;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestDrawingCoreResetSignal:RequestDrawingCoreResetSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

		}

		override protected function onViewSetup():void {

			view.createNewPaintingButtons();

			// Retrieve saved paintings and populate nav.
			// Ordered from newest -> oldest.
			// Always selects the latest one, i.e. index 0.
			// Also requests an easel update on the home view.
			var data:Vector.<PaintingInfoVO> = paintingModel.getSortedPaintingCollection();
			if( data && data.length > 0 ) {
				view.createInProgressPaintings( data );
			}

			view.validateCenterButtons();

			// Auto select first painting.
			if( data ) {
				var vo:PaintingInfoVO = data[ 0 ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				view.selectButtonWithLabel( str );
				paintingModel.activePaintingId = vo.id;
			}

			super.onViewSetup();
		}

		// -----------------------
		// From view.
		// -----------------------

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				// New color painting.
				case NewPaintingSubNavView.ID_NEW: {
					PaintModeModel.activeMode = PaintModeType.COLOR_MODE;
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.activePaintingId = PaintingInfoVO.DEFAULT_VO_ID;
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.HOME_PICK_SURFACE );
					break;
				}

				// New photo painting.
				case NewPaintingSubNavView.ID_NEW_PHOTO: {
					PaintModeModel.activeMode = PaintModeType.PHOTO_MODE;
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.activePaintingId = PaintingInfoVO.DEFAULT_VO_ID;
					pickDefaultSurfaceAndContinueToPickImage();
					break;
				}

				// Continue painting.
				case NewPaintingSubNavView.ID_CONTINUE: {
					trace( "focused: " + paintingModel.activePaintingId );
					if( paintingModel.activePaintingId != "uniqueUserId-" ) {
						requestLoadPaintingDataSignal.dispatch( paintingModel.activePaintingId );
						//TODO: blocker activation
					}
					break;
				}

				//  Paintings.
				default: {
					paintingModel.activePaintingId = "uniqueUserId-" + id;
					var vo:PaintingInfoVO = paintingModel.getVoWithId( "uniqueUserId-" + id );
					requestEaselUpdateSignal.dispatch( vo, true, false );
				}
			}
		}

		private function pickDefaultSurfaceAndContinueToPickImage():void {
			requestStateChange__OLD_TO_REMOVE( NavigationStateType.PICK_IMAGE );
		}
	}
}
