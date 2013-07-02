package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.BinarySaveUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintingModel;
	import net.psykosoft.psykopaint2.core.models.UserModel;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;

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
			if( paintingId == "new" || paintingId == "" ) {

				// Create id and focus model on it.
				paintingId = userModel.uniqueUserId + "-" + dateMs;
				trace( this, "creating a new id: " + paintingId );
				paintingModel.focusedPaintingId = paintingId;

				// Produce data vo.
				vo = new PaintingVO();
				vo.id = paintingId;
				paintingModel.addSinglePaintingData( vo );
			}
			else { // Otherwise just retrieve the vo.
				vo = paintingModel.getVoWithId( paintingId );
			}

			// Update vo.
			vo.lastSavedOnDateMs = dateMs;
			vo.width = canvasModel.width;
			vo.height = canvasModel.height;
			var imagesRGBA:Vector.<ByteArray> = canvasModel.saveLayers();
			vo.colorImageARGB = imagesRGBA[ 0 ];
			vo.heightmapImageARGB = imagesRGBA[ 1 ];
			vo.sourceImageARGB = imagesRGBA[ 2 ];
			trace( this, "using vo: " + vo );

			// Update easel.
			if( updateEasel ) {
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height );
				requestEaselUpdateSignal.dispatch( bmd );
			}

			// Serialize data.
			var voBytes:ByteArray = vo.serialize();

			// Deliver to binary writer.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				BinarySaveUtil.saveToIos( voBytes, CoreSettings.PAINTING_DATA_FOLDER_NAME + "/painting-" + paintingId + CoreSettings.PAINTING_FILE_EXTENSION );
			}
			else {
				BinarySaveUtil.saveToDesktop( voBytes, CoreSettings.PAINTING_DATA_FOLDER_NAME + "/painting-" + paintingId + CoreSettings.PAINTING_FILE_EXTENSION );
			}
		}
	}
}
