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
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.core.signals.RequestPopUpRemovalSignal;
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
		public var requestPopUpDisplaySignal:RequestPopUpDisplaySignal;

		[Inject]
		public var requestPopUpRemovalSignal:RequestPopUpRemovalSignal;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var notifyPaintingSavedSignal:NotifyPaintingSavedSignal;

		private var _paintId:String;
		private var _infoVO:PaintingInfoVO;
		private var _infoBytes:ByteArray;
		private var _dataBytes:ByteArray;

		private const ASYNC_MODE:Boolean = false;

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			trace( this, "incoming painting id: " + paintingId );

			// Display pop up and wait 1 frame before starting the save process ( so the pop up is actually displayed first ).
			requestPopUpDisplaySignal.dispatch( PopUpType.SAVING );
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			context.detain( this );
		}

		private function onEnterFrame( event:Event ):void {
			stage.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			setTimeout( save, 10 );
		}

		private function save():void {

			var factory:PaintingInfoFactory = new PaintingInfoFactory();
			var dataVO:PaintingDataVO = canvasModel.exportPaintingData();
			_infoVO = factory.createFromData( dataVO, paintingId, userModel.uniqueUserId, generateThumbnail() );

			paintingModel.updatePaintingInfo( _infoVO );
			paintingModel.focusedPaintingId = _infoVO.id;

			trace( this, "saving vo: " + _infoVO );

			serializeDataToFiles( _infoVO, dataVO );
		}

		private function serializeDataToFiles( infoVO:PaintingInfoVO, dataVO:PaintingDataVO ):void {
			// Serialize data.
			var infoSerializer:PaintingInfoSerializer = new PaintingInfoSerializer();
			var dataSerializer:PaintingDataSerializer = new PaintingDataSerializer();
			_infoBytes = infoSerializer.serialize( infoVO );
			_dataBytes = dataSerializer.serialize( dataVO );
			trace( this, "info num bytes: " + _infoBytes.length );
			trace( this, "data num bytes: " + _dataBytes.length );

			_paintId = infoVO.id;

			writeInfoBytes();
		}

		private function writeInfoBytes():void {

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
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + _paintId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, _dataBytes, wrapItUp );
			}
			else {
				dataWriteUtil.writeBytesSync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + _paintId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, _dataBytes );
				wrapItUp();
			}
		}

		private function wrapItUp():void {

			// Update easel.
			if( updateEasel ) {
				requestEaselUpdateSignal.dispatch( _infoVO );
			}

			// Remove saving pop up.
			requestPopUpRemovalSignal.dispatch();

			// Notify.
			notifyPaintingSavedSignal.dispatch();

			// Release command.
			context.release( this );
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
