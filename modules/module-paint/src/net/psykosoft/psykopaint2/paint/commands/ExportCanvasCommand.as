package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	
	import eu.alebianco.robotlegs.utils.impl.AsyncCommand;
	
	import net.psykosoft.psykopaint2.base.utils.io.DesktopImageSaveUtil;
	import net.psykosoft.psykopaint2.base.utils.io.IosImageSaveUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportEndedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasExportStartedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateErrorPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

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

		
		[Inject]
		public var requestHidePopUpSignal:RequestHidePopUpSignal;
		
		[Inject]
		public var showPopUpSignal:RequestShowPopUpSignal;
		
		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;
		
		[Inject]
		public var requestUpdateErrorPopupMessage:RequestUpdateErrorPopUpSignal; 
		
		private var _bitmapData : BitmapData;
		

		override public function execute():void {

			showPopUpSignal.dispatch(PopUpType.MESSAGE);
			requestUpdateMessagePopUpSignal.dispatch("DOWNLOAD","Snapshot to camera roll");
			
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
			showPopUpSignal.dispatch(PopUpType.ERROR);
			requestUpdateErrorPopupMessage.dispatch("SAVED","Snapshot is saved in your photos");
			
			//requestHidePopUpSignal.dispatch();
			dispatchComplete( true );
		}
	}
}
