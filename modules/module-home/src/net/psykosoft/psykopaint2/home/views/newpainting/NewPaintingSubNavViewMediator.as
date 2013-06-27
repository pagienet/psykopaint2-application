package net.psykosoft.psykopaint2.home.views.newpainting
{

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.home.views.home.*;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPaintingActivationSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.signals.RequestEaselUpdateSignal;

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
		public var paintingModel:PaintingModel;

		private var _waitingForZoom:Boolean;
		private var _waitingForSnapShot:Boolean;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// Post-init.
			view.setInProgressPaintings( paintingModel.getPaintingData() );

			// From app.
			notifyZoomCompleteSignal.add( onZoomComplete );
			notifyCanvasBitmapSignal.add( onCanvasSnapshot );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case NewPaintingSubNavView.LBL_NEW: {
					// Pick one...
					requestStateChange( StateType.HOME_PICK_SURFACE );
//					navigateToPaintStateWithZoomIn(); // Temporary implementation. TODO: remove when ready
					break;
				}
				case NewPaintingSubNavView.LBL_CONTINUE: {
					var selectedLabel:String = view.getSelectedButtonLabel();
					trace( this, "selected label: " + selectedLabel );
					if( selectedLabel != "" && selectedLabel != NewPaintingSubNavView.LBL_NEW ) {
						requestPaintingLoadSignal.dispatch( selectedLabel );
					}
					break;
				}
				default: { // Default buttons are supposed to be in progress painting buttons.
					var vo:PaintingVO = paintingModel.getVoWithId( label );
					var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height );
					requestEaselPaintingUpdateSignal.dispatch( bmd );
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
