package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestStateChangeSignal;

	public class GoToHomeWithCanvasSnapShotCommand extends TracingCommand
	{
		[Inject]
		public var targetState:String; // From signal.

		[Inject]
		public var notifyCanvasSnapshotSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		public function GoToHomeWithCanvasSnapShotCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Resize canvas to full size. This command is usually triggered from the navigation, so the canvas is probably scaled down.
			// We need a snapshot of the canvas to display in the home view, so we scale it up.
			requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT ) );

			// Request the snapshot.
			notifyCanvasSnapshotSignal.addOnce( onCanvasSnapshotTaken );
			RenderGpuCommand.snapshotScale = 1 / CoreSettings.GLOBAL_SCALING;
			RenderGpuCommand.snapshotRequested = true;
		}

		private function onCanvasSnapshotTaken( snapshot:BitmapData ):void {
			trace( this, "snapshot retrieved, changing state" );
			requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT * 0.76 ) );
			requestStateChangeSignal.dispatch( targetState );
		}
	}
}
