package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageSaveUtil;
	import net.psykosoft.psykopaint2.base.utils.io.IosImageSaveUtil;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
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

			// TODO: should we be using snapshots or obtain color image from canvas model?

			// Request a snapshot and wait for it.
			RenderGpuCommand.snapshotScale = 1;
			RenderGpuCommand.snapshotRequested = true;
			notifyCanvasSnapshotSignal.addOnce( onSnapshotRetrieved );
			context.detain( this );
		}

		private function onSnapshotRetrieved( snapshot:BitmapData ):void {
			trace( this, "snapshot retrieved: " + snapshot.width + "x" + snapshot.height );

			// Chose the appropriate saving service and trigger it.
			if( CoreSettings.RUNNING_ON_iPAD ) IosImageSaveUtil.saveImageToCameraRoll( snapshot );
			else DesktopImageSaveUtil.saveImageToDesktop( snapshot );

			context.release( this );
		}
	}
}
