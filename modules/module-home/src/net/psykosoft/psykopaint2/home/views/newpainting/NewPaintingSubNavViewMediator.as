package net.psykosoft.psykopaint2.home.views.newpainting
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.models.PaintModeType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifySurfaceLoadedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestLoadSurfaceSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class NewPaintingSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:NewPaintingSubNavView;

		[Inject]
		public var requestPaintingActivationSignal:RequestPaintingActivationSignal;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestDrawingCoreResetSignal:RequestDrawingCoreResetSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestInteractionBlockSignal:RequestInteractionBlockSignal;

		[Inject]
		public var requestLoadSurfaceSignal:RequestLoadSurfaceSignal;

		[Inject]
		public var notifySurfaceLoadedSignal:NotifySurfaceLoadedSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;

			displaySavedPaintings();

			if( NewPaintingSubNavView.lastScrollerPosition != 0 )
			view.navigation.setScrollerPosition( NewPaintingSubNavView.lastScrollerPosition );

			// From app.
			notifySurfaceLoadedSignal.add( onSurfaceSet );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onButtonClicked( label:String ):void {
			switch( label ) {

				// New color painting.
				case NewPaintingSubNavView.LBL_NEW: {
					PaintModeModel.activeMode = PaintModeType.COLOR_MODE;
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.focusedPaintingId = PaintingInfoVO.DEFAULT_VO_ID;
					requestStateChange( StateType.HOME_PICK_SURFACE );
					break;
				}

				// New photo painting.
				case NewPaintingSubNavView.LBL_NEW_PHOTO: {
					PaintModeModel.activeMode = PaintModeType.PHOTO_MODE;
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.focusedPaintingId = PaintingInfoVO.DEFAULT_VO_ID;
					pickDefaultSurfaceAndContinueToPickImage();
					break;
				}

				// Continue painting.
				case NewPaintingSubNavView.LBL_CONTINUE: {
					requestPaintingActivationSignal.dispatch( paintingModel.focusedPaintingId );
					requestInteractionBlockSignal.dispatch( true );
					break;
				}

				//  Paintings.
				default: {
					paintingModel.focusedPaintingId = "uniqueUserId-" + label;
					var vo:PaintingInfoVO = paintingModel.getVoWithId( "uniqueUserId-" + label );
					requestEaselUpdateSignal.dispatch( vo, true, false );
					NewPaintingSubNavView.lastSelectedPaintingLabel = label;
					NewPaintingSubNavView.lastScrollerPosition = view.navigation.getScrollerPosition();
				}
			}
		}

		private var _waitingForSurfaceSet:Boolean;

		private function onSurfaceSet():void {
			if( _waitingForSurfaceSet ) {
			   	requestStateChange( StateType.PICK_IMAGE );
				_waitingForSurfaceSet = false;
			}
		}

		private function pickDefaultSurfaceAndContinueToPickImage():void {
			_waitingForSurfaceSet = true;
			requestLoadSurfaceSignal.dispatch( 0 );
		}

		// -----------------------
		// Overrride.
		// -----------------------

		override protected function onStateChange( newState:String ):void {
			if( newState == StateType.TRANSITION_TO_HOME_MODE ){
				NewPaintingSubNavView.lastSelectedPaintingLabel = "";
				NewPaintingSubNavView.lastScrollerPosition = 0;
			}
			super.onStateChange( newState );
		}


		// -----------------------
		// Private.
		// -----------------------

		private function displaySavedPaintings():void {

			// Retrieve saved paintings and populate nav.
			// Ordered from newest -> oldest.
			// Always selects the latest one, i.e. index 0.
			// Also requests an easel update on the home view.
			var data:Vector.<PaintingInfoVO> = paintingModel.getSortedPaintingCollection();
			if( data.length > 0 ) {
				view.setInProgressPaintings( data );
				paintingModel.focusedPaintingId = "uniqueUserId-" + view.getIdForSelectedInProgressPainting();
				var vo:PaintingInfoVO = paintingModel.getVoWithId( paintingModel.focusedPaintingId );
				requestEaselUpdateSignal.dispatch( vo, false, false );
			}
		}
	}
}
