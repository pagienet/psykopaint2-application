package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestCanvasExportSignal;

	public class CanvasSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CanvasSubNavView;

		[Inject]
		public var requestClearCanvasSignal:RequestClearCanvasSignal;

		[Inject]
		public var notifyCanvasSnapshotSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		[Inject]
		public var requestCanvasExportSignal:RequestCanvasExportSignal;

		private var _waitingForSnapshot:Boolean;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// From app.
			notifyCanvasSnapshotSignal.add( onCanvasSnapshotRetrieved );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case CanvasSubNavView.LBL_PICK_AN_IMAGE: {
					requestNavigationToggleSignal.dispatch( -1 );
					requestStateChange( StateType.PICK_IMAGE );
					break;
				}
				case CanvasSubNavView.LBL_PICK_A_SURFACE: {
					requestStateChange( StateType.PICK_SURFACE );
					break;
				}
				case CanvasSubNavView.LBL_PICK_A_BRUSH: {
					requestStateChange( StateType.PAINT_SELECT_BRUSH );
					break;
				}
				case CanvasSubNavView.LBL_HOME: {
					navigateToHomeWithCanvasSnapshot();
					break;
				}
				case CanvasSubNavView.LBL_EXPORT: {
					// TODO: call export service
					break;
				}
				case CanvasSubNavView.LBL_PUBLISH: {
					// TODO: trigger publish process
					break;
				}
				case CanvasSubNavView.LBL_CLEAR: {
					requestClearCanvasSignal.dispatch();
					break;
				}
			}
		}

		private function navigateToHomeWithCanvasSnapshot():void {
			trace( this, "requesting canvas snapshot..." );
			// Request a snapshot from the core and wait for it.
			// Before changing state.
			_waitingForSnapshot = true;
			requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, view.stage.stageWidth, view.stage.stageHeight ) );
			RenderGpuCommand.snapshotRequested = true;
		}

		private function onCanvasSnapshotRetrieved( bmd:BitmapData ):void {
			if( !_waitingForSnapshot ) return;
			trace( this, "snapshot retrieved, changing state" );
			requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, view.stage.stageWidth, view.stage.stageHeight * 0.76 ) );
			_waitingForSnapshot = false;
			requestStateChange( StateType.HOME_ON_EASEL );
		}
	}
}
