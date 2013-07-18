package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
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
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.Jokes;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	import robotlegs.bender.framework.api.IContext;

	public class ExportCanvasCommand extends TracingCommand
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var canvasRenderer:CanvasRenderer;

		[Inject]
		public var requestPopUpDisplaySignal:RequestPopUpDisplaySignal;

		[Inject]
		public var requestPopUpRemovalSignal:RequestPopUpRemovalSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		private var _bitmapData : BitmapData;

		public function ExportCanvasCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			requestPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
			var randomJoke:String = Jokes.JOKES[ Math.floor( Jokes.JOKES.length * Math.random() ) ];
			requestUpdateMessagePopUpSignal.dispatch( "Exporting...", randomJoke );

			_bitmapData = canvasRenderer.renderToBitmapData();

			// Write bmd
			if( CoreSettings.RUNNING_ON_iPAD ) {
				var iosImageSaveUtil:IosImageSaveUtil = new IosImageSaveUtil();
				iosImageSaveUtil.saveImageToCameraRoll( _bitmapData, onWriteComplete );
			}
			else {
				DesktopImageSaveUtil.saveImageToDesktop( _bitmapData );
				onWriteComplete();
			}

		}

		private function onWriteComplete():void {
			requestPopUpRemovalSignal.dispatch();
			_bitmapData.dispose();
		}
	}
}
