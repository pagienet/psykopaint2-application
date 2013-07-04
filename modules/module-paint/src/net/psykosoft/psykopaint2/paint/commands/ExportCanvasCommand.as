package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageSaveUtil;
	import net.psykosoft.psykopaint2.base.utils.io.IosImageSaveUtil;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasSnapshotSignal;

	import robotlegs.bender.framework.api.IContext;

	public class ExportCanvasCommand extends TracingCommand
	{
		[Inject]
		public var notifyCanvasSnapshotSignal:NotifyCanvasSnapshotSignal;

		[Inject]
		public var context:IContext;

		[Inject]
		public var canvasModel:CanvasModel;

		public function ExportCanvasCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// -----------------------
			// Approach 1.
			// PROBLEM: This approach generates an image that lacks the bg.
			// -----------------------

			// Retrieve bmd.
			// TODO: can only save color image?
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayers();
			var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( imagesRGBA[ 0 ], canvasModel.width, canvasModel.height, true );

			// Write bmd
			if( CoreSettings.RUNNING_ON_iPAD ) IosImageSaveUtil.saveImageToCameraRoll( bmd );
			else DesktopImageSaveUtil.saveImageToDesktop( bmd );

			// -----------------------
			// Approach 2.
			// PROBLEM: This approach generates the correct image, but causes subsequent clear canvas calls to fail.
			// -----------------------

			// Request a snapshot and wait for it.
			/*RenderGpuCommand.snapshotScale = 1;
			RenderGpuCommand.snapshotRequested = true;
			notifyCanvasSnapshotSignal.addOnce( onSnapshotRetrieved );
			context.detain( this );*/
		}

		/*private function onSnapshotRetrieved( snapshot:BitmapData ):void {
			trace( this, "snapshot retrieved: " + snapshot.width + "x" + snapshot.height );

			// Chose the appropriate saving service and trigger it.
			if( CoreSettings.RUNNING_ON_iPAD ) IosImageSaveUtil.saveImageToCameraRoll( snapshot );
			else DesktopImageSaveUtil.saveImageToDesktop( snapshot );

			context.release( this );
		}*/
	}
}
