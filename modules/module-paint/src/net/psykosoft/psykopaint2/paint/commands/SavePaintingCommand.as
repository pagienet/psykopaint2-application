package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.BinaryIoUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
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
			var vo:PaintingVO;
			var nowDate:Date = new Date();
			var dateMs:Number = nowDate.getTime();
			if( paintingId == PaintingVO.DEFAULT_VO_ID ) {

				// Create id and focus model on it.
				paintingId = userModel.uniqueUserId + "-" + dateMs;
				trace( this, "creating a new id: " + paintingId );

				// Produce data vo.
				vo = new PaintingVO();
				vo.id = paintingId;
				paintingModel.addSinglePaintingData( vo );
			}
			else { // Otherwise just retrieve the vo.
				vo = paintingModel.getVoWithId( paintingId );
			}
			paintingModel.focusedPaintingId = paintingId;

			// Update vo.
			vo.lastSavedOnDateMs = dateMs;
			vo.width = canvasModel.width;
			vo.height = canvasModel.height;
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayers();
			vo.colorImageBGRA = imagesRGBA[ 0 ];
			vo.heightmapImageBGRA = imagesRGBA[ 1 ];
			vo.sourceImageARGB = imagesRGBA[ 2 ];
			vo.lowResColorImageBGRA = reduceImage( imagesRGBA[ 0 ], vo.width, vo.height );
			vo.lowResHeightmapImageBGRA = reduceImage( imagesRGBA[ 1 ], vo.width, vo.height );
			trace( this, "saving vo: " + vo );

			// Save thumbnail.
			var thumbnail:BitmapData = renderer.renderToBitmapData();
			vo.thumbnail = BitmapDataUtils.scaleBitmapData( thumbnail, 0.25 ); // TODO: apply different scales depending on source and target resolutions

			// Update easel.
			if( updateEasel ) {
				requestEaselUpdateSignal.dispatch( vo );
			}

			// Serialize data.
			var serializer:PaintingSerializer = new PaintingSerializer();
			var bytesInfo:ByteArray = serializer.serializePaintingVoInfo( vo );
			var bytesData:ByteArray = serializer.serializePaintingVoData( vo );
			trace( this, "info num bytes: " + bytesInfo.length );
			trace( this, "data num bytes: " + bytesData.length );

			// Write.
			var infoWriteUtil:BinaryIoUtil;
			var dataWriteUtil:BinaryIoUtil;
			if( CoreSettings.RUNNING_ON_iPAD ) { // iOS
				// Write info.
				infoWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_IOS );
				infoWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingSerializer.PAINTING_INFO_FILE_EXTENSION, bytesInfo, null );
				// Write data.
				dataWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_IOS );
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingSerializer.PAINTING_DATA_FILE_EXTENSION, bytesData, null );
			}
			else { // Desktop
				// Write info.
				infoWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_DESKTOP );
				infoWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingSerializer.PAINTING_INFO_FILE_EXTENSION, bytesInfo, null );
				// Write data.
				dataWriteUtil = new BinaryIoUtil( BinaryIoUtil.STORAGE_TYPE_DESKTOP );
				dataWriteUtil.writeBytesAsync( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/" + paintingId + PaintingSerializer.PAINTING_DATA_FILE_EXTENSION, bytesData, null );
			}
		}

		// TODO: extremely slow, use native approach?
		private function reduceImage( bytes:ByteArray, sourceWidth:uint, sourceHeight:uint ):ByteArray {

			// todo: implement properly, causes runtime error
			return bytes;

			var i:uint, j:uint;
			var li:uint = sourceWidth * PaintingSerializer.LOW_RES_SURFACE_MULTIPLIER;
			var lj:uint = sourceHeight * PaintingSerializer.LOW_RES_SURFACE_MULTIPLIER;

			var reducedBytes:ByteArray = new ByteArray();

			bytes.position = 0;
			for( i = 0; i < li; ++i ) {
				for( j = 0; j < lj; ++j ) {

					// Identify pixel positions.
					var sourceX:uint = 2 * i;
					var sourceY:uint = 2 * j;
					var sourceIndexTL:uint = sourceX + sourceY * sourceWidth;
					var sourceIndexBL:uint = sourceX + ( sourceY + 1 ) * sourceWidth;

					// Read top row pixel pair.
					bytes.position = sourceIndexTL * 4;
					var sourceTL_b:uint = bytes.readInt();
					var sourceTL_g:uint = bytes.readInt();
					var sourceTL_r:uint = bytes.readInt();
					var sourceTL_a:uint = bytes.readInt();
					var sourceTR_b:uint = bytes.readInt();
					var sourceTR_g:uint = bytes.readInt();
					var sourceTR_r:uint = bytes.readInt();
					var sourceTR_a:uint = bytes.readInt();

					// Read bottom row pixel pair.
					bytes.position = sourceIndexBL * 4;
					var sourceBL_b:uint = bytes.readInt();
					var sourceBL_g:uint = bytes.readInt();
					var sourceBL_r:uint = bytes.readInt();
					var sourceBL_a:uint = bytes.readInt();
					var sourceBR_b:uint = bytes.readInt();
					var sourceBR_g:uint = bytes.readInt();
					var sourceBR_r:uint = bytes.readInt();
					var sourceBR_a:uint = bytes.readInt();

					// Average the 4 read pixels.
					var avgB:int = ( sourceTL_b + sourceTR_b + sourceBL_b + sourceBR_b ) * 0.25;
					var avgG:int = ( sourceTL_g + sourceTR_g + sourceBL_g + sourceBR_g ) * 0.25;
					var avgR:int = ( sourceTL_r + sourceTR_r + sourceBL_r + sourceBR_r ) * 0.25;
					var avgA:int = ( sourceTL_a + sourceTR_a + sourceBL_a + sourceBR_a ) * 0.25;

					// Write average into destination.
					reducedBytes.writeInt( avgB );
					reducedBytes.writeInt( avgG );
					reducedBytes.writeInt( avgR );
					reducedBytes.writeInt( avgA );
				}
			}

			return reducedBytes;
		}
	}
}
