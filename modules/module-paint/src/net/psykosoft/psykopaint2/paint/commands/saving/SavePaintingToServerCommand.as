package net.psykosoft.psykopaint2.paint.commands.saving
{
	import com.greensock.TweenLite;
	
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.Stage;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.io.CanvasPublishEvent;
	import net.psykosoft.psykopaint2.core.io.CanvasPublisher;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.LoggedInUserProxy;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.services.AMFBridge;
	import net.psykosoft.psykopaint2.core.signals.NotifyAMFConnectionFailed;
	import net.psykosoft.psykopaint2.core.signals.NotifyDataForPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPopUpRemovedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerStartedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySaveToServerSucceededSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateErrorPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.Jokes;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

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
		public var requestShowPopUpSignal : RequestShowPopUpSignal;

		[Inject]
		public var requestHidePopUpSignal : RequestHidePopUpSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var requestUpdateErrorPopUpSignal:RequestUpdateErrorPopUpSignal;

		[Inject]
		public var notifyAMFConnectionFailed:NotifyAMFConnectionFailed;

		[Inject]
		public var notifyPopUpRemovedSignal:NotifyPopUpRemovedSignal;

		[Inject]
		public var notifyDataForPopUpSignal:NotifyDataForPopUpSignal;

		[Inject]
		public var paintSettings:UserPaintSettingsModel;

		private var _paintingData : PaintingDataVO;
		private var _compositeData : ByteArray;
		private var _bitmapData:BitmapData;


		public function execute():void
		{
			notifySaveToServerStartedSignal.dispatch();
			requestShowPopUpSignal.dispatch( PopUpType.MESSAGE );
			requestUpdateMessagePopUpSignal.dispatch( "Publishing...", Jokes.getRandomJoke() );
			
			//HACK TO MAKE SURE THE POPUP APPEARS BEFORE PROCESSING THE SHIT OUT OF THE BITMAPS
			TweenLite.to(new Object(),0.3,{onComplete:function(){
				var canvasExporter:CanvasPublisher = new CanvasPublisher( stage, ioAne );
				canvasExporter.addEventListener( CanvasPublishEvent.COMPLETE, onExportComplete );
				canvasExporter.exportForPublish( canvasModel, paintSettings, CoreSettings.PUBLISH_JPEG_QUALITY );
				// dispatch notify started signal

			}})
			
		}

		private function onExportComplete( event:CanvasPublishEvent ):void {
			event.target.removeEventListener( CanvasPublishEvent.COMPLETE, onExportComplete );

			_paintingData = event.paintingDataVO;
			grabComposite();
			publish();
		}

		private function grabComposite() : void
		{
			_bitmapData = canvasRenderer.renderToBitmapData();
			_compositeData = _bitmapData.encode(_bitmapData.rect, new JPEGEncoderOptions(CoreSettings.PUBLISH_JPEG_QUALITY))
		}

		private function publish() : void
		{
			notifyAMFConnectionFailed.add(onPublishFail);
			amfBridge.publishPainting(loggedInUserProxy.sessionID, _paintingData, _compositeData, paintSettings.hasSourceImage, onPublishComplete, onPublishFail);
		}

		private function onPublishComplete(data : Object) : void
		{
			trace(data);
			if (data["status_code"] != 1) {
				showErrorPopUp();
				trace ("Publish unsuccesful with error code: " + data["status_code"]);
				cleanUp();
				return;
			}
			else {
				trace ("Publish successful");
				requestHidePopUpSignal.dispatch();
				notifyPopUpRemovedSignal.addOnce(onPublishPopUpRemoved);
				notifySaveToServerSucceededSignal.dispatch();
				
				
				
			}
		}

		private function onPublishPopUpRemoved():void {

			requestShowPopUpSignal.dispatch(PopUpType.SHARE);

			// Send bmd to whoever wants to listen.
			notifyDataForPopUpSignal.dispatch([_bitmapData.clone()]);

			cleanUp();
		}

		private function onPublishFail(data : Object) : void
		{
			cleanUp();
			showErrorPopUp();
			trace ("Publish unsuccesful: call failed");
		}

		private function showErrorPopUp():void
		{
			requestShowPopUpSignal.dispatch(PopUpType.ERROR);
			requestUpdateErrorPopUpSignal.dispatch("Publish error", "Make sure you have a working internet connection!")
		}

		private function cleanUp() : void
		{
			notifyAMFConnectionFailed.remove(onPublishFail);
			_bitmapData.dispose();
			_paintingData.dispose();
			_compositeData.clear();
			_paintingData = null;
			_compositeData = null;
		}
	}
}
