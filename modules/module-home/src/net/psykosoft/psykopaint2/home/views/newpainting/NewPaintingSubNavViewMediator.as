package net.psykosoft.psykopaint2.home.views.newpainting
{

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.SavingProcessModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSavedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewDeleteModeChangedSignal;
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
		public var notifyPaintingDataSavedSignal:NotifyPaintingDataSavedSignal;
		
		[Inject]
		public var notifyHomeViewDeleteModeChangedSignal:NotifyHomeViewDeleteModeChangedSignal;
		
		[Inject]
		public var savingProcessModel:SavingProcessModel;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			view.deleteModeSignal = notifyHomeViewDeleteModeChangedSignal;
			// From app.
			notifyPaintingDataSavedSignal.add( onPaintingDataSaved );
		}

		override public function destroy():void {
			notifyPaintingDataSavedSignal.remove( onPaintingDataSaved );
			super.destroy();
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			ensureLatestPaintingIsOnEasel(); // TODO: check first if there is no need to do this?
		}

		override protected function onViewDisabled():void {
			super.onViewDisabled();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function continueToPhotoPainting():void {
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

			super.onViewSetup();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				// New color painting.
				case NewPaintingSubNavView.ID_NEW: {
					if ( !view.deleteModeActive )
					{
						requestDrawingCoreResetSignal.dispatch();
						paintingModel.activePaintingId = "psyko-" + PaintingInfoVO.DEFAULT_VO_ID;
						requestNavigationStateChange( NavigationStateType.PICK_IMAGE );
					} else {
						view.toggleDeleteMode();
						if( data && data.length > 0 ) {
							view.selectButtonWithLabel(data[0].id.split("-")[1] );
							requestEaselUpdateSignal.dispatch( data[0], true, null );
						} else {
							requestEaselUpdateSignal.dispatch( null, true, null );
						}
					}
					break;
				}
				/*
				// New photo painting.
				case NewPaintingSubNavView.ID_NEW_PHOTO: {
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.activePaintingId = "psyko-" + PaintingInfoVO.DEFAULT_VO_ID;
					requestNavigationStateChange( NavigationStateType.PICK_IMAGE );
					break;
				}
				*/
				//  Paintings.
				default: {
//					view.showRightButton( true );
					if ( !view.deleteModeActive )
					{
						if( paintingModel.activePaintingId == "psyko-" + id ) {
							continueToPhotoPainting();
						} else {
							paintingModel.activePaintingId = "psyko-" + id;
							var vo:PaintingInfoVO = paintingModel.getVoWithId( paintingModel.activePaintingId );
							trace( this, "clicked on painting: " + vo.id );
							requestEaselUpdateSignal.dispatch( vo, true, null );
						
						}
					} else {
						view.removePainting( id );
						var data:Vector.<PaintingInfoVO> = paintingModel.getSortedPaintingCollection();
						if( data && data.length > 0 ) {
							view.selectButtonWithLabel(data[0].id.split("-")[1] );
							requestEaselUpdateSignal.dispatch( data[0], true, null );
						} else {
							requestEaselUpdateSignal.dispatch( null, true, null );
						}
						
					}
				}
			}
		}

		private function ensureLatestPaintingIsOnEasel():void {
			var infoVO:PaintingInfoVO = paintingModel.getVoWithId( paintingModel.activePaintingId );
			if( infoVO )
			{
				requestEaselUpdateSignal.dispatch( infoVO, true, null );
				view.selectButtonWithLabel(infoVO.id.split("-")[1]);
				
			} else
			{
				var data:Vector.<PaintingInfoVO> = paintingModel.getSortedPaintingCollection();
				if( data && data.length > 0 ) {
					
					infoVO = data[ 0 ];
					if( infoVO )
					{
						requestEaselUpdateSignal.dispatch( infoVO, true, null );
						view.selectButtonWithLabel(infoVO.id.split("-")[1]);
					}
				}
			}
			if( infoVO ) paintingModel.activePaintingId = infoVO.id;
		}
	}
}
