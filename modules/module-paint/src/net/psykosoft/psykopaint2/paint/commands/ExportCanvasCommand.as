package net.psykosoft.psykopaint2.paint.commands
{

	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageSaveUtil;
	import net.psykosoft.psykopaint2.base.utils.io.IosImageSaveUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportEndedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportStartedSignal;

	public class ExportCanvasCommand extends AsyncCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		[Inject]
		public var notifyCanvasExportStartedSignal:NotifyCanvasExportStartedSignal;

		[Inject]
		public var notifyCanvasExportEndedSignal:NotifyCanvasExportEndedSignal;

		private var _bitmapData : BitmapData;

		override public function execute():void {

			_bitmapData = canvasRenderer.renderToBitmapData();

			notifyCanvasExportStartedSignal.dispatch();

			// Write bmd
			if( CoreSettings.RUNNING_ON_iPAD ) {
				var iosImageSaveUtil:IosImageSaveUtil = new IosImageSaveUtil();
				iosImageSaveUtil.saveImageToCameraRoll( _bitmapData, onWriteComplete );
			}
			else {
				var desktopImageSaveUtil:DesktopImageSaveUtil = new DesktopImageSaveUtil();
				desktopImageSaveUtil.saveImageToDesktop( _bitmapData, onWriteComplete );
			}

			// TODO: listen for fail.
		}

		private function onWriteComplete():void {
			_bitmapData.dispose();
			notifyCanvasExportEndedSignal.dispatch();
			dispatchComplete( true );
		}
	}
}
