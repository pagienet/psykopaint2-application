package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
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

		private var _fileStream:FileStream;
		private var _bytes:ByteArray;

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
			trace( this, "saving vo: " + vo );

			// Save thumbnail.
			var thumbnail:BitmapData = renderer.renderToBitmapData();
			vo.thumbnail = BitmapDataUtils.scaleBitmapData( thumbnail, 0.25 ); // TODO: apply different scales depending on source and target resolutions

			// Update easel.
			if( updateEasel ) {
				requestEaselUpdateSignal.dispatch( vo );
			}

			// Serialize data.
			_bytes = vo.serialize();

			// Write.
			context.detain( this );
			if( CoreSettings.RUNNING_ON_iPAD ) { // iOS
				writeBytesAsync(
						File.applicationStorageDirectory.resolvePath( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/painting-" + paintingId + PaintingVO.PAINTING_FILE_EXTENSION )
				);
			}
			else { // Desktop
				writeBytesAsync(
						File.desktopDirectory.resolvePath( CoreSettings.PAINTING_DATA_FOLDER_NAME + "/painting-" + paintingId + PaintingVO.PAINTING_FILE_EXTENSION )
				);
			}
		}

		private function writeBytesAsync( file:File ):void {
			trace( this, "writing bytes..." );
			_fileStream = new FileStream();
			_fileStream.addEventListener( Event.CLOSE, onWriteBytesAsyncClosed );
			_fileStream.addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onWriteBytesAsyncProgress );
			_fileStream.openAsync( file, FileMode.WRITE );
			_fileStream.writeBytes( _bytes );
		}

		private function onWriteBytesAsyncProgress( event:OutputProgressEvent ):void {
//			trace( this, "writing bytes progress: " + event.bytesPending );
			if( event.bytesPending == 0 ) {
				_fileStream.close();
			}
		}

		private function onWriteBytesAsyncClosed( event:Event ):void {
			trace( this, "done writing bytes." );
			context.release( this );
		}
	}
}
