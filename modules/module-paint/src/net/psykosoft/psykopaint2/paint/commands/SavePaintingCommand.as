package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoFactory;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.io.CanvasExportEvent;
	import net.psykosoft.psykopaint2.core.io.CanvasExporter;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpRemovalSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPaintingSavedSignal;

	import robotlegs.bender.framework.api.IContext;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var updateEasel:Boolean; // From signal.

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var userModel:UserModel;

		[Inject]
		public var paintingModel:PaintingModel;

		[Inject]
		public var requestEaselUpdateSignal:RequestEaselUpdateSignal;

		[Inject]
		public var context:IContext;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		[Inject]
		public var notifyMemoryWarningSignal:NotifyMemoryWarningSignal;

		[Inject]
		public var canvasHistoryModel:CanvasHistoryModel;

		[Inject]
		public var requestPopUpDisplaySignal:RequestPopUpDisplaySignal;

		[Inject]
		public var requestPopUpRemovalSignal:RequestPopUpRemovalSignal;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		private var _paintId:String;
		private var _infoBytes:ByteArray;
		private var _dataBytes:ByteArray;
		private var _infoVO : PaintingInfoVO;

		private const ASYNC_MODE:Boolean = false;

		/*
		* NOTE: Jul 18, 2013
		* SAVING IS DISABLED ON iPAD - PaintingModel data is populated, but the actual file writing is disabled.
		* RetrievePaintingDataCommand.as is also disabled.
		* Line 107
		* */

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			trace( this, "incoming painting id: " + paintingId );

			// Saving is disabled on iPad because it's too unstable.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				exitCommand();
				return;
			}

			context.detain( this );

			// Skip saving if the painting is not dirty.
			var isPaintingDirty:Boolean = canvasHistoryModel.hasHistory;
			trace( "is painting dirty: " + isPaintingDirty );
			if( !isPaintingDirty ) {
				exitCommand();
				return;
			}

			// Listen for memory warnings and exit if one shows up during the saving process.
			// Written data seems to be corrupted in such cases.
			// TODO: make sure data being written is deleted completely
			// TODO: think about what better reaction to have on such cases and what is really happening
			notifyMemoryWarningSignal.add( onMemoryWarning );

			// Show a pop up during the process.
			requestPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
			requestUpdateMessagePopUpSignal.dispatch( "saving..." );

			// Wait a bit before starting the save process so we actually give the pop a chance to show.
			setTimeout( save, 100 );
		}

		private function save():void {
			requestUpdateMessagePopUpSignal.dispatch( "saving: exporting..." );
			var canvasExporter : CanvasExporter = new CanvasExporter();
			canvasExporter.addEventListener(CanvasExportEvent.COMPLETE, onExportComplete);
			canvasExporter.export(canvasModel);
		}

		// ---------------------------------------------------------------------
		// Export and serialization.
		// ---------------------------------------------------------------------

		private function onExportComplete(event : CanvasExportEvent) : void
		{
			event.target.removeEventListener(CanvasExportEvent.COMPLETE, onExportComplete);
			var factory:PaintingInfoFactory = new PaintingInfoFactory();
			var dataVO : PaintingDataVO = event.paintingDataVO;

			// TODO: This should become disposed after saving
			if (_infoVO) {
				trace ("disposing previous thumbnail");
				_infoVO.dispose();
			}

			_infoVO = factory.createFromData( dataVO, paintingId, userModel.uniqueUserId, generateThumbnail() );

			paintingModel.updatePaintingInfo( _infoVO );
			paintingModel.focusedPaintingId = _infoVO.id;

			trace( this, "saving vo: " + _infoVO );

			serializeDataToFiles( _infoVO, dataVO );
		}

		private function serializeDataToFiles( infoVO:PaintingInfoVO, dataVO:PaintingDataVO ):void {

			requestUpdateMessagePopUpSignal.dispatch( "saving: serializing..." );

			var infoSerializer:PaintingInfoSerializer = new PaintingInfoSerializer();
			var dataSerializer:PaintingDataSerializer = new PaintingDataSerializer();
			_infoBytes = infoSerializer.serialize( infoVO );
			_dataBytes = dataSerializer.serialize( dataVO );
			trace( this, "info num bytes: " + _infoBytes.length );
			trace( this, "data num bytes: " + _dataBytes.length );

			_paintId = infoVO.id;

			writeInfoBytes();
		}

		// ---------------------------------------------------------------------
		// Writing to disc.
		// ---------------------------------------------------------------------

		private function writeInfoBytes():void {

			requestUpdateMessagePopUpSignal.dispatch( "saving: writing..." );

			// TODO: using sync saving for now, async makes writing fail on ipad slow packaging, see notes here: https://github.com/psykosoft/psykopaint2-application/issues/47

			var infoWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			// Write info.
			infoWriteUtil = new BinaryIoUtil( storageType );
			if( ASYNC_MODE ) {
				infoWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + _paintId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, _infoBytes, writeDataBytes );
			}
			else {
				infoWriteUtil.writeBytesSync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + _paintId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, _infoBytes );
				writeDataBytes();
			}
		}

		private function writeDataBytes():void {

			var dataWriteUtil:BinaryIoUtil;
			var storageType:String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			// Write data.
			dataWriteUtil = new BinaryIoUtil( storageType );
			if( ASYNC_MODE ) {
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + _paintId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, _dataBytes, preExitCommand );
			}
			else {
				dataWriteUtil.writeBytesSync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + _paintId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, _dataBytes );
				preExitCommand();
			}
		}

		// ---------------------------------------------------------------------
		// Exit.
		// ---------------------------------------------------------------------

		private function preExitCommand():void {

			requestUpdateMessagePopUpSignal.dispatch( "saving: finishing..." );

			if( updateEasel ) {
				requestEaselUpdateSignal.dispatch( _infoVO );
			}

			notifyMemoryWarningSignal.remove( onMemoryWarning );
			requestPopUpRemovalSignal.dispatch();

			exitCommand();
		}

		private function exitCommand():void {
			notifyPaintingSavedSignal.dispatch();
			context.release( this );
		}

		// ---------------------------------------------------------------------
		// Event listeners.
		// ---------------------------------------------------------------------

		private function onMemoryWarning():void {
			// TODO: a memory warning seems to mean that the saving process has failed, we need to check if anything was written and
			// delete it, to avoid saving corrupted data that could cause errors on load and incorrectly use the available storage space
			preExitCommand();
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function generateThumbnail():BitmapData {
			// TODO: generate thumbnail by accepting scale in renderToBitmapData
			var thumbnail:BitmapData = renderer.renderToBitmapData();
			var scaledThumbnail:BitmapData = BitmapDataUtils.scaleBitmapData( thumbnail, 0.25 ); // TODO: apply different scales depending on source and target resolutions
			thumbnail.dispose();
			return scaledThumbnail;
		}
	}
}
