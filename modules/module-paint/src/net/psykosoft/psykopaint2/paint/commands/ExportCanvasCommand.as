package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageSaveUtil;
	import net.psykosoft.psykopaint2.base.utils.io.IosImageSaveUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.io.CanvasExportEvent;
	import net.psykosoft.psykopaint2.core.io.CanvasExporter;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	import robotlegs.bender.framework.api.IContext;

	public class ExportCanvasCommand extends TracingCommand
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var canvasModel:CanvasModel;

		public function ExportCanvasCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// TODO: Replace this with CanvasRenderer::renderToBitmapData
			var canvasExporter : CanvasExporter = new CanvasExporter();
			canvasExporter.addEventListener(CanvasExportEvent.COMPLETE, onExportComplete);
			canvasExporter.export(canvasModel);
		}

		private function onExportComplete(event : CanvasExportEvent) : void
		{
			event.target.removeEventListener(CanvasExportEvent.COMPLETE, onExportComplete);
			var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( event.paintingDataVO.colorData, canvasModel.width, canvasModel.height, true );

			// Write bmd
			if( CoreSettings.RUNNING_ON_iPAD ) IosImageSaveUtil.saveImageToCameraRoll( bmd );
			else DesktopImageSaveUtil.saveImageToDesktop( bmd );
		}
	}
}
