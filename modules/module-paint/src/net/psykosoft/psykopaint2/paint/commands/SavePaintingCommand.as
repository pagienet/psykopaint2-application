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

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			trace( this, "incoming painting id: " + paintingId );

			// Need to create a new id and vo?
			var infoVO:PaintingInfoVO;
			var nowDate:Date = new Date();
			var dateMs:Number = nowDate.getTime();
			if( paintingId == PaintingInfoVO.DEFAULT_VO_ID ) {

				// Create id and focus model on it.
				paintingId = userModel.uniqueUserId + "-" + dateMs;
				trace( this, "creating a new id: " + paintingId );

				// Produce data vo.
				infoVO = new PaintingInfoVO();
				infoVO.id = paintingId;
				paintingModel.addSinglePaintingData( infoVO );
			}
			else { // Otherwise just retrieve the vo.
				infoVO = paintingModel.getVoWithId( paintingId );
			}
			paintingModel.focusedPaintingId = paintingId;

			// Update vo.
			infoVO.lastSavedOnDateMs = dateMs;
			infoVO.width = canvasModel.width / PaintingInfoDeserializer.SURFACE_PREVIEW_SHRINK_FACTOR;
			infoVO.height = canvasModel.height / PaintingInfoDeserializer.SURFACE_PREVIEW_SHRINK_FACTOR;
			var surfaces:Vector.<ByteArray> = canvasModel.saveLayers();
			infoVO.colorSurfacePreview = reduceSurface( surfaces[ 0 ], canvasModel.width, canvasModel.height, PaintingInfoDeserializer.SURFACE_PREVIEW_SHRINK_FACTOR );
			infoVO.normalsSurfacePreview = reduceSurface( surfaces[ 1 ], canvasModel.width, canvasModel.height, PaintingInfoDeserializer.SURFACE_PREVIEW_SHRINK_FACTOR );
			var dataVO:PaintingDataVO = new PaintingDataVO();
			dataVO.surfaces = surfaces;
			dataVO.width = canvasModel.width;
			dataVO.height = canvasModel.height;
			trace( this, "saving vo: " + infoVO );

			// Save thumbnail.
			var thumbnail:BitmapData = renderer.renderToBitmapData();
			infoVO.thumbnail = BitmapDataUtils.scaleBitmapData( thumbnail, 0.25 ); // TODO: apply different scales depending on source and target resolutions

			// Update easel.
			if( updateEasel ) {
				requestEaselUpdateSignal.dispatch( infoVO );
			}

			// Serialize data.
			var infoSerializer:PaintingInfoSerializer = new PaintingInfoSerializer();
			var dataSerializer:PaintingDataSerializer = new PaintingDataSerializer();
			var bytesInfo:ByteArray = infoSerializer.serialize( infoVO );
			var bytesData:ByteArray = dataSerializer.serialize( dataVO );
			trace( this, "info num bytes: " + bytesInfo.length );
			trace( this, "data num bytes: " + bytesData.length );

			// Write.
			var infoWriteUtil:BinaryIoUtil;
			var dataWriteUtil:BinaryIoUtil;
			if( CoreSettings.RUNNING_ON_iPAD ) { // iOS
				// Write info.
				infoWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_IOS );
				infoWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, bytesInfo, null );
				// Write data.
				dataWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_IOS );
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, bytesData, null );
			}
			else { // Desktop
				// Write info.
				infoWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_DESKTOP );
				infoWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_INFO_FILE_EXTENSION, bytesInfo, null );
				// Write data.
				dataWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_DESKTOP );
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingFileUtils.PAINTING_DATA_FILE_EXTENSION, bytesData, null );
			}
		}

		// TODO: extremely slow, use native approach?
		private function reduceSurface( bytes:ByteArray, sourceWidth:uint, sourceHeight:uint, factor:uint ):ByteArray {
			// TODO: Li: remove and test code below
			return bytes;

			var outputWidth : uint = sourceWidth / factor;
			var outputHeight : uint = sourceHeight / factor;
			var reducedBytes:ByteArray = new ByteArray();
			var startX : uint, startY : uint = 0;

			for( var y : uint = 0; y < outputHeight; ++y ) {
				startX = 0;
				var endY : uint = startY + factor;
				if (endY > sourceHeight) endY = sourceHeight;

				for( var x : uint = 0; x < outputWidth; ++x ) {
					var numSamples : uint = 0;
					var sampledB : uint = 0, sampledG : uint = 0, sampledR : uint = 0, sampledA : uint = 0;

					var endX : uint = startX + factor;
					if (endX > sourceWidth) endX = sourceWidth;

					for (var sampleY : uint = startY; sampleY < endY; ++sampleY) {
						bytes.position = (startX + sampleY*sourceWidth) << 2;
						for (var sampleX : uint = startX; sampleX < endX; ++sampleX) {
							var val : uint = bytes.readUnsignedInt();
							sampledB += (val & 0xff000000) >> 24;
							sampledG += (val & 0x00ff0000) >> 16;
							sampledR += (val & 0x0000ff00) >> 8;
							sampledA += val & 0x000000ff;
	                        ++numSamples;
						}
					}

					var invSamples : Number = 1/numSamples;
					sampledB = uint(sampledB * invSamples) & 0xff;
					sampledG = uint(sampledG * invSamples) & 0xff;
					sampledR = uint(sampledR * invSamples) & 0xff;
					sampledA = uint(sampledA * invSamples) & 0xff;

					// Write average into destination.
					reducedBytes.writeUnsignedInt( (sampledB << 24) | (sampledG << 16) | (sampledR << 8) | sampledA );

					startX += factor;
				}
				startY += factor;
			}
			return reducedBytes;
		}
	}
}
