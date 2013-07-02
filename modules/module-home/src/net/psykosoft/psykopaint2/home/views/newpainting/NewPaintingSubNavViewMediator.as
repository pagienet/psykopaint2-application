package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestDrawingCoreResetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

	public class NewPaintingSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:NewPaintingSubNavView;

		[Inject]
		public var requestZoomToggleSignal:RequestZoomToggleSignal;

		[Inject]
		public var notifyZoomCompleteSignal:NotifyZoomCompleteSignal;

		[Inject]
		public var notifyCanvasBitmapSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var requestEaselPaintingUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestPaintingLoadSignal:RequestPaintingActivationSignal;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var requestDrawingCoreResetSignal:RequestDrawingCoreResetSignal;

		[Inject]
		public var paintingModel:PaintingModel;

		private var _waitingForZoom:Boolean;
		private var _waitingForSnapShot:Boolean; // TODO: remove these 2

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.navigation.buttonClickedCallback = onButtonClicked;

			// Post-init.
			var data:Vector.<PaintingVO> = paintingModel.getPaintingData();
			if( data.length > 0 ) {
				if( data.length > 1 ) {
					data.sort( sortOnLastSavedOnDateMs );
				}
				view.setInProgressPaintings( data );
				paintingModel.focusedPaintingId = view.getIdForSelectedInProgressPainting();
				var vo:PaintingVO = paintingModel.getVoWithId( paintingModel.focusedPaintingId );
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height, true );
				requestEaselUpdateSignal.dispatch( bmd, null );
			}
			else{
				requestEaselUpdateSignal.dispatch( null );
			}

			// From app.
			notifyZoomCompleteSignal.add( onZoomComplete );
			notifyCanvasBitmapSignal.add( onCanvasSnapshot );
		}

		private function sortOnLastSavedOnDateMs( paintingVOA:PaintingVO, paintingVOB:PaintingVO ):Number {
			if( paintingVOA.lastSavedOnDateMs > paintingVOB.lastSavedOnDateMs ) return 1;
			else if( paintingVOA.lastSavedOnDateMs < paintingVOB.lastSavedOnDateMs ) return -1;
			else return 0;
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case NewPaintingSubNavView.LBL_NEW: {
					requestDrawingCoreResetSignal.dispatch();
					paintingModel.focusedPaintingId = PaintingVO.DEFAULT_VO_ID;
					requestStateChange( StateType.HOME_PICK_SURFACE );
					break;
				}
				case NewPaintingSubNavView.LBL_CONTINUE: {
					requestPaintingLoadSignal.dispatch( paintingModel.focusedPaintingId );
					break;
				}
				default: { // Default buttons are supposed to be in progress painting buttons.
					var vo:PaintingVO = paintingModel.getVoWithId( label );
					var diffuseBmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height, true );
					var normalBmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height, false );
					paintingModel.focusedPaintingId = label;
					requestEaselPaintingUpdateSignal.dispatch( diffuseBmd, normalBmd );
					break;
				}
			}
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onZoomComplete():void {
			if( !_waitingForZoom ) return;
			_waitingForZoom = false;
			_waitingForSnapShot = true;
			requestStateChange( StateType.GOING_TO_PAINT );
			RenderGpuCommand.snapshotScale = 1;
			RenderGpuCommand.snapshotRequested = true;
		}

		private function onCanvasSnapshot( bmd:BitmapData ):void {
			if( !_waitingForSnapShot ) return;
			_waitingForSnapShot = false;
			requestStateChange( StateType.PAINT );
		}

		// -----------------------
		// Private.
		// -----------------------

		private function navigateToPaintStateWithZoomIn():void {
			_waitingForZoom = true;
		    requestZoomToggleSignal.dispatch( true );
		}
	}
}
