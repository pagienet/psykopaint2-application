package net.psykosoft.psykopaint2.home.views.home
{

	import flash.display.BitmapData;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyZoomCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestZoomToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

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

		private var _waitingForZoom:Boolean;
		private var _waitingForSnapShot:Boolean;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// From app.
			notifyZoomCompleteSignal.add( onZoomComplete );
			notifyCanvasBitmapSignal.add( onCanvasSnapshot );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case NewPaintingSubNavView.LBL_PAINT: {
					navigateToPaintStateWithZoomIn();
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
