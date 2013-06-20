package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;

	import robotlegs.bender.framework.api.IContext;

	public class ExportCanvasCommand extends TracingCommand
	{
		[Inject]
		public var notifyCanvasSnapshotSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var context:IContext;

		public function ExportCanvasCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Request a snapshot and wait for it.
			RenderGpuCommand.snapshotRequested = true; // TODO: request full snapshot here, atm it produces scaled down snapshots...
			notifyCanvasSnapshotSignal.addOnce( onSnapshotRetrieved );
			context.detain( this );
		}

		private function onSnapshotRetrieved( snapshot:BitmapData ):void {
			trace( this, "snapshot retrieved: " + snapshot.width + "x" + snapshot.height );

			// Chose the appropriate saving service and trigger it.
			// TODO...
		}
	}
}
