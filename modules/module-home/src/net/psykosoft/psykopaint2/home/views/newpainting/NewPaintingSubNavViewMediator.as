package net.psykosoft.psykopaint2.home.views.newpainting
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.EaselModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselTappedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.signals.RequestHomePanningToggleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataFileSignal;

	public class NewPaintingSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:NewPaintingSubNavView;

		[Inject]
		public var requestLoadPaintingDataSignal:RequestLoadPaintingDataFileSignal;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestDrawingCoreResetSignal:RequestDrawingCoreResetSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestHomePanningToggleSignal:RequestHomePanningToggleSignal;

		[Inject]
		public var notifyPaintingDataSavedSignal:NotifyPaintingDataSavedSignal;

		[Inject]
		public var savingProcessModel:SavingProcessModel;

		[Inject]
		public var notifyEaselTappedSignal:NotifyEaselTappedSignal;

		[Inject]
		public var easelModel:EaselModel;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From app.
			notifyPaintingDataSavedSignal.add( onPaintingDataSaved );
		}

		override public function destroy():void {
			notifyPaintingDataSavedSignal.remove( onPaintingDataSaved );
			super.destroy();
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			notifyEaselTappedSignal.add( onEaselTapped );
			ensureLatestPaintingIsOnEasel(); // TODO: check first if there is no need to do this?
		}

		override protected function onViewDisabled():void {
			super.onViewDisabled();
			notifyEaselTappedSignal.remove( onEaselTapped );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onEaselTapped():void {
			trace( "focused: " + paintingModel.activePaintingId );
			requestLoadPaintingDataSignal.dispatch( paintingModel.activePaintingId );
		}

		private function onPaintingDataSaved( success:Boolean ):void {
			ConsoleView.instance.log( this, "knows of painting data saved..." );
			view.enableDisabledButtons();
			view.showRightButton( true );
		}

		// -----------------------
		// From view.
		// -----------------------

		override protected function onViewSetup():void {

			ConsoleView.instance.log( this, "view set up" );

			view.createNewPaintingButtons();

			// Retrieve saved paintings and populate nav.
			// Ordered from newest -> oldest.
			// Always selects the latest one, i.e. index 0.
			// Also requests an easel update on the home view.
			var data:Vector.<PaintingInfoVO> = paintingModel.getSortedPaintingCollection();
			if( data && data.length > 0 ) {
				view.createInProgressPaintings( data, savingProcessModel.paintingId );
			}

			view.validateCenterButtons();

			// Auto select first painting.
			if( data && data.length > 0 ) {
				var vo:PaintingInfoVO = data[ 0 ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				view.selectButtonWithLabel( str );
				paintingModel.activePaintingId = vo.id;
			}

			super.onViewSetup();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				// New color painting.
				case NewPaintingSubNavView.ID_NEW: {
					PaintModeModel.activeMode = PaintMode.COLOR_MODE;
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.activePaintingId = "psyko-" + PaintingInfoVO.DEFAULT_VO_ID;
					requestNavigationStateChange( NavigationStateType.HOME_PICK_SURFACE );
					requestHomePanningToggleSignal.dispatch( -1 );
					break;
				}

				// New photo painting.
				case NewPaintingSubNavView.ID_NEW_PHOTO: {
					PaintModeModel.activeMode = PaintMode.PHOTO_MODE;
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.activePaintingId = "psyko-" + PaintingInfoVO.DEFAULT_VO_ID;
					requestNavigationStateChange( NavigationStateType.PICK_IMAGE );
					requestHomePanningToggleSignal.dispatch( -1 );
					break;
				}

				//  Paintings.
				default: {
//					view.showRightButton( true );
					paintingModel.activePaintingId = "psyko-" + id;
					var vo:PaintingInfoVO = paintingModel.getVoWithId( paintingModel.activePaintingId );
					trace( this, "clicked on painting: " + vo.id );
					requestEaselUpdateSignal.dispatch( vo, true, false );
				}
			}
		}

		private function ensureLatestPaintingIsOnEasel():void {
			var data:Vector.<PaintingInfoVO> = paintingModel.getSortedPaintingCollection();
			if( data && data.length > 0 ) {
				var infoVO:PaintingInfoVO = data[ 0 ];
				if( infoVO ) {
					if( !easelModel.currentVO || easelModel.currentVO.id != infoVO.id ) {
						requestEaselUpdateSignal.dispatch( infoVO, true, false );
					}
				}
			}
		}
	}
}
