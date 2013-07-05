package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingDataSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.data.PaintingFileUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoDeserializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoFactory;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

	import robotlegs.bender.framework.api.IContext;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId : String; // From signal.

		[Inject]
		public var updateEasel : Boolean; // From signal.

		[Inject]
		public var canvasModel : CanvasModel;

		[Inject]
		public var userModel : UserModel;

		[Inject]
		public var paintingModel : PaintingModel;

		[Inject]
		public var requestEaselUpdateSignal : RequestEaselUpdateSignal;

		[Inject]
		public var context : IContext;

		[Inject]
		public var renderer : CanvasRenderer;

		public function SavePaintingCommand()
		{
			super();
		}

		override public function execute() : void
		{
			super.execute();

			trace(this, "incoming painting id: " + paintingId);

			var factory : PaintingInfoFactory = new PaintingInfoFactory();
			var dataVO : PaintingDataVO = canvasModel.exportPaintingData();
			var infoVO : PaintingInfoVO = factory.createFromData(dataVO, paintingId, userModel.uniqueUserId, generateThumbnail());

			paintingModel.updatePaintingInfo(infoVO);
			paintingModel.focusedPaintingId = infoVO.id;

			trace(this, "saving vo: " + infoVO);

			// Update easel.
			if (updateEasel) {
				requestEaselUpdateSignal.dispatch(infoVO);
			}

			serializeDataToFiles(infoVO, dataVO);
		}

		private function serializeDataToFiles(infoVO : PaintingInfoVO, dataVO : PaintingDataVO) : void
		{
			// Serialize data.
			var infoSerializer : PaintingInfoSerializer = new PaintingInfoSerializer();
			var dataSerializer : PaintingDataSerializer = new PaintingDataSerializer();
			var bytesInfo : ByteArray = infoSerializer.serialize(infoVO);
			var bytesData : ByteArray = dataSerializer.serialize(dataVO);
			trace(this, "info num bytes: " + bytesInfo.length);
			trace(this, "data num bytes: " + bytesData.length);

			writeData(infoVO.id, bytesInfo, bytesData);
		}

		private function generateThumbnail() : BitmapData
		{
			// TODO: generate thumbnail by accepting scale in renderToBitmapData
			var thumbnail : BitmapData = renderer.renderToBitmapData();
			var scaledThumbnail : BitmapData = BitmapDataUtils.scaleBitmapData(thumbnail, 0.25); // TODO: apply different scales depending on source and target resolutions
			thumbnail.dispose();
			return scaledThumbnail;
		}

		private function writeData(paintId : String, bytesInfo : ByteArray, bytesData : ByteArray) : void
		{
			// Write.
			var infoWriteUtil : BinaryIoUtil;
			var dataWriteUtil : BinaryIoUtil;
			var storageType : String = CoreSettings.RUNNING_ON_iPAD ? BinaryIoUtil.STORAGE_TYPE_IOS : BinaryIoUtil.STORAGE_TYPE_DESKTOP;

			// Write info.
			infoWriteUtil = new BinaryIoUtil(storageType);
			infoWriteUtil.writeBytesAsync(CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, bytesInfo, null);
			// Write data.
			dataWriteUtil = new BinaryIoUtil(storageType);
			dataWriteUtil.writeBytesAsync(CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, bytesData, null);
		}
	}
}
