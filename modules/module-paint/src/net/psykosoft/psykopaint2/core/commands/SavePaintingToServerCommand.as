package net.psykosoft.psykopaint2.core.commands
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;

	import flash.display.Stage;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.io.CanvasPublishEvent;
	import net.psykosoft.psykopaint2.core.io.CanvasPublisher;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerFailedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerStartedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerSucceededSignal;

	public class SavePaintingToServerCommand
	{
		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var ioAne:IOAneManager;

		[Inject]
		public var amfBridge : AMFBridge;

		[Inject]
		public var loggedInUserProxy : LoggedInUserProxy;

		[Inject]
		public var canvasRenderer : CanvasRenderer;

		[Inject]
		public var notifySaveToServerStartedSignal : NotifySaveToServerStartedSignal;

		[Inject]
		public var notifySaveToServerSucceededSignal : NotifySaveToServerSucceededSignal;

		[Inject]
		public var notifySaveToServerFailedSignal : NotifySaveToServerFailedSignal;

		private var _paintingData : PaintingDataVO;
		private var _compositeData : ByteArray;

		public function execute():void
		{
			notifySaveToServerStartedSignal.dispatch();

			// dispatch notify started signal
			var canvasExporter:CanvasPublisher = new CanvasPublisher( stage, ioAne );
			canvasExporter.addEventListener( CanvasPublishEvent.COMPLETE, onExportComplete );
			canvasExporter.exportForPublish( canvasModel, CoreSettings.PUBLISH_JPEG_QUALITY );
		}

		private function onExportComplete( event:CanvasPublishEvent ):void {
			event.target.removeEventListener( CanvasPublishEvent.COMPLETE, onExportComplete );

			_paintingData = event.paintingDataVO;
			grabComposite();
			publish();
		}

		private function grabComposite() : void
		{
			var bitmapData : BitmapData = canvasRenderer.renderToBitmapData();
			_compositeData = bitmapData.encode(bitmapData.rect, new JPEGEncoderOptions(CoreSettings.PUBLISH_JPEG_QUALITY))
			bitmapData.dispose();
		}

		private function publish() : void
		{
			amfBridge.publishPainting(loggedInUserProxy.sessionID, _paintingData, _compositeData, onPublishComplete, onPublishFail);
		}

		private function onPublishComplete(data : Object) : void
		{
			cleanUp();

				if (data["status_code"] != 1) {
				notifySaveToServerFailedSignal.dispatch(data["status_code"], data["status_reason"]);
				return;
			}
			else
				notifySaveToServerSucceededSignal.dispatch();
		}

		private function onPublishFail(data : Object) : void
		{
			cleanUp();
			notifySaveToServerFailedSignal.dispatch(data["status_code"], "CALL_FAILED");
		}

		private function cleanUp() : void
		{
			_paintingData.dispose();
			_compositeData.clear();
			_paintingData = null;
			_compositeData = null;
		}
	}
}
